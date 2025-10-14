// home_page.dart - UPDATED FOR PER-USER DATA
import 'package:expense_track/Login/Login.dart';
import 'package:expense_track/Provider/balance_provider.dart';
import 'package:expense_track/graph/graph.dart';
import 'package:expense_track/models/transaction_model.dart';
import 'package:expense_track/screens/expense_page.dart';
import 'package:expense_track/screens/income_page.dart';
import 'package:expense_track/screens/overview.dart';
import 'package:expense_track/services/auth_service.dart';
import 'package:expense_track/transaction/recent10.dart';
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
          // Add logout button
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
              Provider.of<BalanceProvider>(context, listen: false).clearUser();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          ),
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
              'AED ${balanceProvider.formattedBalance}',
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

            // Recent transactions using the updated BalanceProvider stream
            RecentTransactionsWidget(),
          ],
        ),
      ),
    );
  }
}

// // NEW: Recent Transactions Section that uses BalanceProvider streams
// class RecentTransactionsSection extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final balanceProvider = Provider.of<BalanceProvider>(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 16.0),
//           child: Text(
//             'Recent Transactions',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//         ),
//         StreamBuilder<List<TransactionModel>>(
//           stream: balanceProvider.getLast10TransactionsStream(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }

//             if (snapshot.hasError) {
//               return Text('Error loading transactions');
//             }

//             final transactions = snapshot.data ?? [];

//             if (transactions.isEmpty) {
//               return Container(
//                 padding: EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     Icon(Icons.receipt_long, size: 64, color: Colors.grey),
//                     SizedBox(height: 16),
//                     Text(
//                       'No transactions yet',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     Text(
//                       'Add your first income or expense!',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return ListView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: transactions.length,
//               itemBuilder: (context, index) {
//                 final transaction = transactions[index];
//                 return RecentTransactionCard(transaction: transaction);
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

// // NEW: Transaction Card Widget
// class RecentTransactionCard extends StatelessWidget {
//   final TransactionModel transaction;

//   const RecentTransactionCard({super.key, required this.transaction});

//   @override
//   Widget build(BuildContext context) {
//     final isIncome = transaction.isIncome;

//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 4),
//       child: ListTile(
//         leading: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: isIncome
//                 ? Colors.green.withOpacity(0.2)
//                 : Colors.red.withOpacity(0.2),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             isIncome ? Icons.arrow_upward : Icons.arrow_downward,
//             color: isIncome ? Colors.green : Colors.red,
//           ),
//         ),
//         title: Text(
//           transaction.description,
//           style: TextStyle(fontWeight: FontWeight.w500),
//         ),
//         subtitle: Text(
//           transaction.category,
//           style: TextStyle(color: Colors.grey[600]),
//         ),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               'AED ${transaction.amount.toStringAsFixed(2)}',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: isIncome ? Colors.green : Colors.red,
//               ),
//             ),
//             Text(
//               '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
