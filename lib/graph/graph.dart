import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/balance_provider.dart'; // Updated import
import '../models/transaction_model.dart';

class SpendChart extends StatefulWidget {
  const SpendChart({super.key});

  @override
  State<SpendChart> createState() => _SpendChartState();
}

class _SpendChartState extends State<SpendChart> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<FlSpot> _graphData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<FlSpot> _getGraphData(
    List<TransactionModel> transactions,
    int tabIndex,
  ) {
    final now = DateTime.now();

    final filtered = transactions.where((tx) {
      final txDate = tx.date;
      final diff = now.difference(txDate);
      switch (tabIndex) {
        case 0: // Today
          return diff.inDays == 0 &&
              txDate.day == now.day &&
              txDate.month == now.month &&
              txDate.year == now.year;
        case 1: // Week
          return diff.inDays < 7;
        case 2: // Month
          return diff.inDays < 30;
        case 3: // Year
          return diff.inDays < 365;
        default:
          return true;
      }
    }).toList();

    filtered.sort((a, b) => a.date.compareTo(b.date));

    return List.generate(filtered.length, (i) {
      double amount = filtered[i].amount;
      return FlSpot(i.toDouble(), amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionModel>>(
      stream: Provider.of<BalanceProvider>(
        context,
      ).getLast10TransactionsStream(),
      builder: (context, snapshot) {
        List<TransactionModel> transactions = [];

        if (snapshot.hasData) {
          transactions = snapshot.data!;
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading chart data',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final graphData = _getGraphData(transactions, _tabController.index);

        return Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: graphData.isEmpty
                  ? Center(
                      child: Text(
                        'No data for selected period',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: graphData.isNotEmpty ? graphData.last.x : 1,
                        minY: 0,
                        maxY: graphData.isNotEmpty
                            ? graphData
                                      .map((e) => e.y)
                                      .reduce((a, b) => a > b ? a : b) *
                                  1.1
                            : 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: graphData,
                            isCurved: true,
                            barWidth: 4,
                            color: Colors.lightBlue,
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color.fromARGB(22, 3, 168, 244),
                            ),
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
            ),
            TabBar(
              splashFactory: NoSplash.splashFactory,
              // ignore: deprecated_member_use
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              dividerHeight: 0,
              controller: _tabController,
              labelColor: Colors.lightBlue,
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                color: const Color.fromARGB(74, 3, 168, 244),
                borderRadius: BorderRadius.circular(25),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(8),
              tabs: const [
                Tab(text: "Today"),
                Tab(text: "Week"),
                Tab(text: "Month"),
                Tab(text: "Year"),
              ],
            ),
          ],
        );
      },
    );
  }
}
