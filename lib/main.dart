import 'package:expense_track/app/core/providers/balance_provider.dart';
import 'package:expense_track/app/core/providers/category_provider.dart';
import 'package:expense_track/app/core/providers/currency_provider.dart';
import 'package:expense_track/app/core/services/auth_service.dart';
import 'package:expense_track/app/features/authentication/login_screen.dart';
import 'package:expense_track/app/features/home/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // <-- import your generated file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for current platform (web included)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProxyProvider<CurrencyProvider, BalanceProvider>(
          create: (context) => BalanceProvider(Provider.of<CurrencyProvider>(context, listen: false)),
          update: (context, currencyProvider, previous) =>
              BalanceProvider(currencyProvider),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder(
        stream: authService.getCurrentUserStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.blue),
              ),
            );
          }

          // If user is logged in, go to Home Page
          if (snapshot.hasData) {
            return HomePage();
          }

          // Otherwise show login page
          return LoginPage();
        },
      ),
    );
  }
}
