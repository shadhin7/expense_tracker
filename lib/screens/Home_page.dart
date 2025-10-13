// home_page.dart
import 'package:expense_track/Provider/balance_provider.dart'; // Updated import
import 'package:expense_track/graph/graph.dart';
import 'package:expense_track/models/transaction_model.dart';
import 'package:expense_track/screens/expense_page.dart';
import 'package:expense_track/screens/income_page.dart';
import 'package:expense_track/transaction/recent10.dart';
import 'package:expense_track/screens/overview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final balanceProvider = Provider.of<BalanceProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 248, 248, 248),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Overview()),
                );
              },
              color: Colors.blueGrey,
              icon: Icon(Icons.person),
            ),
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Account Balance',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            // Balance will now update in real-time via the provider
            Text(
              'AED ${balanceProvider.balance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => IncomePage()),
                  ),
                  child: Container(
                    height: 80,
                    width: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.green,
                    ),
                    alignment: Alignment.center,
                    child: ListTile(
                      textColor: Colors.white,
                      title: Text('Income'),
                      subtitle: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          text: balanceProvider.formattedTotalIncome,
                        ),
                      ),
                      leading: Image.asset('assets/images/inc.png'),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ExpensePage()),
                  ),
                  child: Container(
                    height: 80,
                    width: 170,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.red,
                    ),
                    alignment: Alignment.center,
                    child: ListTile(
                      textColor: Colors.white,
                      leading: Image.asset('assets/images/ex.png'),
                      title: Text('Expense'),
                      subtitle: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          text: balanceProvider.formattedTotalExpense,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            SizedBox(height: 16),

            // Graph section - will update in real-time via provider
            SpendChart(),

            // Recent transactions using Firestore stream
            RecentTransactionsWidget(),
          ],
        ),
      ),
    );
  }
}

// Updated RecentTransactions to use Firestore stream
// class RecentTransactionsWithStream extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final balanceProvider = Provider.of<BalanceProvider>(context);

//     return StreamBuilder<List<TransactionModel>>(
//       stream: balanceProvider.getLast10TransactionsStream(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Text('Error loading transactions: ${snapshot.error}');
//         }

//         final transactions = snapshot.data ?? [];

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16.0),
//               child: Text(
//                 'Recent Transactions',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//             if (transactions.isEmpty)
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   'No transactions yet',
//                   style: TextStyle(color: Colors.grey),
//                   textAlign: TextAlign.center,
//                 ),
//               )
//             else
//               ...transactions
//                   .map(
//                     (transaction) => TransactionTile(
//                       transaction: transaction,
//                       onTap: () {
//                         // You can add edit functionality here if needed
//                       },
//                     ),
//                   )
//                   .toList(),
//           ],
//         );
//       },
//     );
//   }
// }

// Simple transaction tile widget (you might already have this)
class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: transaction.isIncome
                ? Colors.green.shade100
                : Colors.red.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            transaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: transaction.isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(transaction.description),
        subtitle: Text(transaction.category),
        trailing: Text(
          'AED ${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: transaction.isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
