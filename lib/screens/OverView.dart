import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_track/Provider/balance_provider.dart'; // ✅ Updated import
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  DateTime selectedMonth = DateTime.now();

  void _selectMonth(BuildContext context) async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedMonth = picked;
      });
      Provider.of<BalanceProvider>(context, listen: false).loadMonth(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceProvider = Provider.of<BalanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Overview"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () => _selectMonth(context),
            icon: const Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "View: ${DateFormat.yMMM().format(selectedMonth)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),
            Card(
              color: Colors.green.shade100,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                title: const Text("Total Income"),
                trailing: Text(
                  "AED ${balanceProvider.totalIncome.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              color: Colors.red.shade100,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.red),
                title: const Text("Total Expense"),
                trailing: Text(
                  "AED ${balanceProvider.totalExpense.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              color: Colors.blue.shade100,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.blue,
                ),
                title: const Text("Account Balance"),
                trailing: Text(
                  "AED ${balanceProvider.balance.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
