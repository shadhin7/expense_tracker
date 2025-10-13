// recent10.dart
import 'package:expense_track/Provider/balance_provider.dart';
import 'package:expense_track/models/transaction_model.dart';
import 'package:expense_track/screens/history_page.dart';
import 'package:expense_track/transaction/iconstest.dart';
import 'package:expense_track/screens/transaction_detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RecentTransactionsWidget extends StatelessWidget {
  const RecentTransactionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final balanceProvider = Provider.of<BalanceProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Transaction",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const History()),
                  );
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        StreamBuilder<List<TransactionModel>>(
          stream: balanceProvider.getLast10TransactionsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading transactions',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final transactions = snapshot.data ?? [];

            if (transactions.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No recent transactions.'),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isIncome = tx.isIncome;
                final imagePath = getCategoryImage(tx.category, tx.type);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
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
                                tx.id!, // ✅ FIXED: Pass the ID, not the object
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  style: TextStyle(color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${isIncome ? '+' : '-'} AED ${tx.amount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isIncome ? Colors.green : Colors.red,
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
            );
          },
        ),
      ],
    );
  }
}
