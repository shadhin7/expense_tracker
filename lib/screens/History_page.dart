// history_page.dart - FIXED VERSION
import 'package:expense_track/Provider/balance_provider.dart';
import 'package:expense_track/transaction/iconstest.dart';
import 'package:expense_track/screens/transaction_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  DateTime selectedMonth = DateTime.now();

  void _pickMonth(BuildContext context) async {
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
    final provider = Provider.of<BalanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => _pickMonth(context),
            icon: const Icon(Icons.filter_alt),
          ),
        ],
        leading: const BackButton(),
        title: const Text("Transaction History"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Showing: ${DateFormat.yMMM().format(selectedMonth)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // Monthly Summary
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Income',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'AED ${provider.totalIncome.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Expense',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'AED ${provider.totalExpense.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Balance',
                        style: TextStyle(
                          color: provider.balance >= 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'AED ${provider.balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Transactions List
          Expanded(
            child: provider.transactions.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No transactions found for this month.'),
                    ),
                  )
                : ListView.builder(
                    itemCount: provider.transactions.length,
                    itemBuilder: (context, index) {
                      final entry = provider.transactions[index];
                      final tx = entry.transaction;
                      final isIncome = tx.isIncome;
                      final imagePath = getCategoryImage(tx.category, tx.type);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionDetailPage(
                                  transaction: tx,
                                  transactionId:
                                      entry.key, // ✅ This should work now
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                // Icon
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isIncome
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.asset(
                                    imagePath,
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.category,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        tx.description.toLowerCase(),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),

                                // Amount + Time
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${isIncome ? '+' : '-'} AED ${tx.amount.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isIncome
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${tx.date.day}/${tx.date.month}/${tx.date.year}",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('hh:mm a').format(tx.date),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
