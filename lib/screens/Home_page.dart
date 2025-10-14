import 'package:expense_track/Login/Login.dart';
import 'package:expense_track/Provider/balance_provider.dart';
import 'package:expense_track/graph/graph.dart';
import 'package:expense_track/screens/ProfilePage.dart';
import 'package:expense_track/screens/expense_page.dart';
import 'package:expense_track/screens/income_page.dart';
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
  void initState() {
    super.initState();
    // Initialize user data when home page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserData();
    });
  }

  void _initializeUserData() {
    final auth = Provider.of<AuthService>(context, listen: false);
    final balanceProvider = Provider.of<BalanceProvider>(
      context,
      listen: false,
    );

    if (auth.currentUser != null) {
      print('🏠 HomePage: Initializing data for user ${auth.currentUser!.uid}');
      balanceProvider.setUser(auth.currentUser!.uid);
    } else {
      print('❌ HomePage: No user logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceProvider = Provider.of<BalanceProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfilePage()),
            );
          },
          icon: Icon(Icons.person_outline),
        ),
        actions: [
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
                  child: SizedBox(
                    height: 80,
                    width: 175,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(25),
                      ),
                      color: Colors.green,
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
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ExpensePage()),
                  ),
                  child: SizedBox(
                    height: 80,
                    width: 175,
                    child: Card(
                      color: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(25),
                      ),

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
                ),
              ],
            ),
            SizedBox(height: 24),
            SizedBox(height: 16),

            // Graph section - will update in real-time via provider
            SpendChart(),

            RecentTransactionsWidget(),
          ],
        ),
      ),
    );
  }
}
