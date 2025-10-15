import 'package:expense_track/Login/Login.dart';
import 'package:expense_track/Provider/balance_provider.dart';
import 'package:expense_track/graph/graph.dart';
import 'package:expense_track/screens/Income_page.dart';
import 'package:expense_track/screens/ProfilePage.dart';
import 'package:expense_track/screens/expense_page.dart';
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
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    // Breakpoints
    const mobileMax = 700.0;
    const tabletMax = 1024.0;

    // Responsive sizing helpers
    double titleSize() {
      if (width <= mobileMax) return 18;
      if (width <= tabletMax) return 20;
      return 22;
    }

    double balanceSize() {
      if (width <= mobileMax) return 26;
      if (width <= tabletMax) return 32;
      return 40;
    }

    double cardHeight() {
      if (width <= mobileMax) return 90;
      if (width <= tabletMax) return 110;
      return 130;
    }

    BorderRadius cardRadius = BorderRadius.circular(18);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Dashboard"),
        centerTitle: true,
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
        padding: EdgeInsets.symmetric(
          horizontal: width <= mobileMax ? 12 : 24,
          vertical: 16,
        ),
        child: Center(
          child: ConstrainedBox(
            // limit content width for very wide screens (desktop)
            constraints: BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Account Balance',
                  style: TextStyle(
                    fontSize: titleSize(),
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'AED ${balanceProvider.formattedBalance}',
                  style: TextStyle(
                    fontSize: balanceSize(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                // Cards layout: always show as row, wrap if not enough space
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => IncomePage()),
                            ),
                            child: SizedBox(
                              height: cardHeight(),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: cardRadius,
                                ),
                                color: Colors.green,
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  textColor: Colors.white,
                                  title: Text('Income'),
                                  subtitle: Text(
                                    balanceProvider.formattedTotalIncome,
                                    style: TextStyle(
                                      fontSize: width <= mobileMax ? 14 : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  leading: Image.asset(
                                    'assets/images/inc.png',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ExpensePage()),
                            ),
                            child: SizedBox(
                              height: cardHeight(),
                              child: Card(
                                color: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: cardRadius,
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  textColor: Colors.white,
                                  leading: Image.asset(
                                    'assets/images/ex.png',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                  ),
                                  title: Text('Expense'),
                                  subtitle: Text(
                                    balanceProvider.formattedTotalExpense,
                                    style: TextStyle(
                                      fontSize: width <= mobileMax ? 14 : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 20),
                // Graph section - constrain width for large screens so chart isn't stretched
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: width <= mobileMax ? double.infinity : 900,
                    minWidth: 0,
                  ),
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SpendChart(),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Recent transactions - allow it to take available width but not exceed max
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1200),
                  child: RecentTransactionsWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
