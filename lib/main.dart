// main.dart
import 'package:expense_track/Provider/balance_provider.dart'; // Updated provider
import 'package:expense_track/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Firebase options - you'll need to add your own configuration
import 'firebase_options.dart'; // This will be generated

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase instead of Hive
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BalanceProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}
