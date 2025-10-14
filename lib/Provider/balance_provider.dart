// balance_provider.dart - FINAL VERSION
import 'package:expense_track/models/tansaction_entry.dart';
import 'package:expense_track/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';

import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class BalanceProvider with ChangeNotifier {
  double _balance = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;
  List<TransactionEntry> _transactions = [];
  String? _currentUserId;

  final FirestoreService _firestoreService = FirestoreService();

  double get balance => _balance;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  List<TransactionEntry> get transactions => _transactions;

  String get formattedBalance => formatAmount(_balance);
  String get formattedTotalIncome => formatAmount(_totalIncome);
  String get formattedTotalExpense => formatAmount(_totalExpense);

  BalanceProvider() {
    _initializeUserData();
  }

  // Initialize with user data
  void _initializeUserData() {
    // This will be called when the app starts
    // We'll manually check for current user in build methods
  }

  // Call this method when you know the user is logged in
  void setUser(String userId) {
    _currentUserId = userId;
    _loadCurrentMonthData();
  }

  // Clear data when user logs out
  void clearUser() {
    _currentUserId = null;
    _balance = 0;
    _totalIncome = 0;
    _totalExpense = 0;
    _transactions = [];
    notifyListeners();
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

    if (_getMonthKey(tx.date) == _getMonthKey(DateTime.now())) {
      _transactions.add(TransactionEntry(tx.id!, tx));
      _balance += tx.amount;
      _totalIncome += tx.amount;
      notifyListeners();
    }
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

    if (_getMonthKey(tx.date) == _getMonthKey(DateTime.now())) {
      _transactions.add(TransactionEntry(tx.id!, tx));
      _balance -= tx.amount;
      _totalExpense += tx.amount;
      notifyListeners();
    }
  }

  // Delete Transaction with Firestore
  Future<void> deleteTransaction(String transactionId) async {
    if (_currentUserId == null) return;
    await _firestoreService.deleteTransaction(transactionId, _currentUserId!);
    _loadCurrentMonthData();
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

    final wasIncome = existingTransaction.isIncome;
    final isCurrentMonth =
        _getMonthKey(existingTransaction.date) == _getMonthKey(DateTime.now());

    // Revert old values if in current month
    if (isCurrentMonth) {
      if (wasIncome) {
        _balance -= existingTransaction.amount;
        _totalIncome -= existingTransaction.amount;
      } else {
        _balance += existingTransaction.amount;
        _totalExpense -= existingTransaction.amount;
      }
    }

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

    if (isCurrentMonth) {
      if (wasIncome) {
        _balance += newAmount;
        _totalIncome += newAmount;
      } else {
        _balance -= newAmount;
        _totalExpense += newAmount;
      }

      // Update transaction in local list
      final index = _transactions.indexWhere(
        (entry) => entry.key == transactionId,
      );
      if (index != -1) {
        _transactions[index] = TransactionEntry(transactionId, updated);
      }
    }

    notifyListeners();
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

  // Load Month Data
  void _loadMonthData(DateTime targetDate) {
    if (_currentUserId == null) return;

    final monthKey = _getMonthKey(targetDate);

    _balance = 0;
    _totalIncome = 0;
    _totalExpense = 0;
    _transactions = [];

    // Listen to Firestore stream for this month
    _firestoreService
        .getMonthlyTransactionsStream(monthKey, _currentUserId!)
        .listen((transactions) {
          _balance = 0;
          _totalIncome = 0;
          _totalExpense = 0;
          _transactions = [];

          for (final tx in transactions) {
            _transactions.add(TransactionEntry(tx.id!, tx));
            if (tx.isIncome) {
              _balance += tx.amount;
              _totalIncome += tx.amount;
            } else {
              _balance -= tx.amount;
              _totalExpense += tx.amount;
            }
          }

          notifyListeners();
        });
  }

  // Stream Methods
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
