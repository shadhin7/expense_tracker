// main.dart - CORRECTED VERSION
import 'package:expense_track/Login/Login.dart';
import 'package:expense_track/Provider/balance_provider.dart';
import 'package:firebase_core/firebase_core.dart'; // ADD THIS IMPORT
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';

void main() async {
  // ADD async
  WidgetsFlutterBinding.ensureInitialized(); // ADD THIS
  await Firebase.initializeApp(); // ADD THIS - CRITICAL!

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => BalanceProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}
