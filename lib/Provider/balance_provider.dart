// balance_provider.dart - FIXED VERSION
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:expense_track/models/tansaction_entry.dart';
import 'package:expense_track/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';

class BalanceProvider with ChangeNotifier {
  double _balance = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;
  List<TransactionEntry> _transactions = [];
  String? _currentUserId;
  StreamSubscription? _monthlySubscription; // Add this

  final FirestoreService _firestoreService = FirestoreService();

  double get balance => _balance;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  List<TransactionEntry> get transactions => _transactions;

  String get formattedBalance => formatAmount(_balance);
  String get formattedTotalIncome => formatAmount(_totalIncome);
  String get formattedTotalExpense => formatAmount(_totalExpense);

  @override
  void dispose() {
    _monthlySubscription?.cancel(); // Important: cancel subscription
    super.dispose();
  }

  // Call this method when you know the user is logged in
  void setUser(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      _cancelCurrentSubscription(); // Cancel any existing subscription
      _loadCurrentMonthData();
    }
  }

  // Clear data when user logs out
  void clearUser() {
    _cancelCurrentSubscription(); // Cancel subscription
    _currentUserId = null;
    _balance = 0;
    _totalIncome = 0;
    _totalExpense = 0;
    _transactions = [];
    notifyListeners();
  }

  void _cancelCurrentSubscription() {
    _monthlySubscription?.cancel();
    _monthlySubscription = null;
  }

  String _getMonthKey(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  // Add Income with Firestore
  Future<void> addIncome(
    double amount,
    String category,
    String description,
    String wallet,
    String? capturedImagePath,
  ) async {
    if (_currentUserId == null) return;

    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: 'income',
      date: DateTime.now(),
      category: category,
      description: description,
      wallet: wallet,
      imagePath: capturedImagePath,
      userId: _currentUserId!,
    );

    await _firestoreService.addTransaction(tx, _currentUserId!);

    // Don't update local state here - let the stream handle it
    // This ensures consistency across devices
  }

  // Add Expense with Firestore
  Future<void> addExpense(
    double amount,
    String category,
    String description,
    String wallet,
    String? capturedImagePath,
  ) async {
    if (_currentUserId == null) return;

    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: 'expense',
      date: DateTime.now(),
      category: category,
      description: description,
      wallet: wallet,
      imagePath: capturedImagePath,
      userId: _currentUserId!,
    );

    await _firestoreService.addTransaction(tx, _currentUserId!);

    // Don't update local state here - let the stream handle it
  }

  // Delete Transaction with Firestore
  Future<void> deleteTransaction(String transactionId) async {
    if (_currentUserId == null) return;
    await _firestoreService.deleteTransaction(transactionId, _currentUserId!);
    // Stream will automatically update
  }

  // Edit Transaction with Firestore
  Future<void> editTransaction(
    String transactionId,
    double newAmount,
    String newCategory,
    String newDescription,
    String newWallet,
    String? newImagePath,
  ) async {
    if (_currentUserId == null) return;

    final existingTransaction = await _firestoreService.getTransaction(
      transactionId,
      _currentUserId!,
    );
    if (existingTransaction == null) return;

    // Create updated transaction
    final updated = TransactionModel(
      id: transactionId,
      amount: newAmount,
      type: existingTransaction.type,
      date: existingTransaction.date,
      category: newCategory,
      description: newDescription,
      wallet: newWallet,
      imagePath: newImagePath,
      userId: _currentUserId!,
    );

    await _firestoreService.updateTransaction(updated, _currentUserId!);
    // Stream will automatically update
  }

  // Load Current Month Data
  void _loadCurrentMonthData() {
    if (_currentUserId == null) return;
    _loadMonthData(DateTime.now());
  }

  // Load Specific Month Data
  void loadMonth(DateTime selectedDate) {
    if (_currentUserId == null) return;
    _loadMonthData(selectedDate);
  }

  // FIXED: Load Month Data with proper stream management
  void _loadMonthData(DateTime targetDate) {
    if (_currentUserId == null) {
      return;
    }

    // Cancel any existing subscription
    _cancelCurrentSubscription();

    final monthKey = _getMonthKey(targetDate);

    // Clear data immediately
    _balance = 0;
    _totalIncome = 0;
    _totalExpense = 0;
    _transactions = [];
    notifyListeners(); // Notify that we're clearing data

    // Set up new subscription
    _monthlySubscription = _firestoreService
        .getMonthlyTransactionsStream(monthKey, _currentUserId!)
        .listen(
          (transactions) {
            // Reset calculations
            double newBalance = 0;
            double newTotalIncome = 0;
            double newTotalExpense = 0;
            List<TransactionEntry> newTransactions = [];

            // Calculate new values
            for (final tx in transactions) {
              newTransactions.add(TransactionEntry(tx.id!, tx));
              if (tx.isIncome) {
                newBalance += tx.amount;
                newTotalIncome += tx.amount;
              } else {
                newBalance -= tx.amount;
                newTotalExpense += tx.amount;
              }
            }

            // Update state only if values changed
            if (_balance != newBalance ||
                _totalIncome != newTotalIncome ||
                _totalExpense != newTotalExpense ||
                _transactions.length != newTransactions.length) {
              _balance = newBalance;
              _totalIncome = newTotalIncome;
              _totalExpense = newTotalExpense;
              _transactions = newTransactions;

              notifyListeners();
            }
          },
          onError: (error) {
            notifyListeners();
          },
        );
  }

  // Stream Methods (unchanged)
  Stream<List<TransactionModel>> getMonthlyTransactionsStream(String monthKey) {
    if (_currentUserId == null) return Stream.value([]);
    return _firestoreService.getMonthlyTransactionsStream(
      monthKey,
      _currentUserId!,
    );
  }

  Stream<List<TransactionModel>> getLast10TransactionsStream() {
    if (_currentUserId == null) return Stream.value([]);
    return _firestoreService.getLast10TransactionsStream(_currentUserId!);
  }

  Stream<Map<String, double>> getMonthlySummaryStream(DateTime date) {
    if (_currentUserId == null) return Stream.value({});
    final monthKey = _getMonthKey(date);
    return _firestoreService.getMonthlySummaryStream(monthKey, _currentUserId!);
  }

  Stream<List<String>> getAvailableMonthsStream() {
    if (_currentUserId == null) return Stream.value([]);
    return _firestoreService.getAvailableMonthsStream(_currentUserId!);
  }
}

// Format helper (unchanged)
String formatAmount(double amount) {
  if (amount >= 10000) {
    return "${(amount / 1000).toStringAsFixed(1)}k";
  } else {
    return amount.toStringAsFixed(2);
  }
}

// Month picker (unchanged)
void pickMonth(BuildContext context) async {
  final selected = await showMonthPicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );

  if (selected != null) {
    Provider.of<BalanceProvider>(context, listen: false).loadMonth(selected);
  }
}
