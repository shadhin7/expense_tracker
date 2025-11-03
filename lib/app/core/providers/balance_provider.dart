// balance_provider.dart - UPDATED WITH CARRY-FORWARD BALANCE
import 'package:expense_track/app/core/models/tansaction_entry.dart';
import 'package:expense_track/app/core/models/transaction_model.dart';
import 'package:expense_track/app/core/providers/currency_provider.dart';
import 'package:expense_track/app/core/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '../services/cloudinary_service.dart';

class BalanceProvider with ChangeNotifier {
  double _balance = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;
  List<TransactionEntry> _transactions = [];
  String? _currentUserId;
  bool _isUploadingImage = false;

  final FirestoreService _firestoreService = FirestoreService();
  // final CloudinaryService _cloudinaryService = CloudinaryService();
  final CurrencyProvider? _currencyProvider;

  double get balance => _balance;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  List<TransactionEntry> get transactions => _transactions;
  bool get isUploadingImage => _isUploadingImage;

  String get formattedBalance {
    if (_currencyProvider == null) {
      return _balance.toStringAsFixed(2);
    }
    final convertedBalance = _currencyProvider.convert(
      _balance,
      'AED', // Assuming the base currency is AED
      _currencyProvider.selectedCurrency,
    );
    return convertedBalance.toStringAsFixed(2);
  }

  String get formattedTotalIncome {
    if (_currencyProvider == null) {
      return _totalIncome.toStringAsFixed(2);
    }
    final convertedTotalIncome = _currencyProvider.convert(
      _totalIncome,
      'AED', // Assuming the base currency is AED
      _currencyProvider.selectedCurrency,
    );
    return convertedTotalIncome.toStringAsFixed(2);
  }

  String get formattedTotalExpense {
    if (_currencyProvider == null) {
      return _totalExpense.toStringAsFixed(2);
    }
    final convertedTotalExpense = _currencyProvider.convert(
      _totalExpense,
      'AED', // Assuming the base currency is AED
      _currencyProvider.selectedCurrency,
    );
    return convertedTotalExpense.toStringAsFixed(2);
  }

  BalanceProvider(this._currencyProvider) {
    _initializeUserData();
  }

  // Initialize with user data
  void _initializeUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      _loadInitialData(); // Load all-time balance and current month's transactions
    }
  }

  // Set user and load initial data
  void setUser(String userId) {
    _currentUserId = userId;
    _loadInitialData();
  }

  // Clear data on logout
  void clearUser() {
    _currentUserId = null;
    _balance = 0;
    _totalIncome = 0;
    _totalExpense = 0;
    _transactions = [];
    _isUploadingImage = false;
    notifyListeners();
  }

  String _getMonthKey(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  String? get currentUserId => _currentUserId;

  // Load all-time balance and current month's transactions
  void _loadInitialData() {
    if (_currentUserId == null) return;

    // Get the total balance from all transactions
    _firestoreService.getAllTransactionsStream(_currentUserId!).listen((
      allTransactions,
    ) {
      double totalBalance = 0;
      for (final tx in allTransactions) {
        if (tx.isIncome) {
          totalBalance += tx.amount;
        } else {
          totalBalance -= tx.amount;
        }
      }
      _balance = totalBalance;

      // After getting the all-time balance, load current month's details
      _loadMonthData(DateTime.now(), keepBalance: true);
    });
  }

  // Load data for a specific month
  void loadMonth(DateTime selectedDate) {
    if (_currentUserId == null) return;
    _loadMonthData(selectedDate);
  }

  // Load monthly transaction data
  void _loadMonthData(DateTime targetDate, {bool keepBalance = false}) {
    if (_currentUserId == null) return;

    final monthKey = _getMonthKey(targetDate);

    // Listen to Firestore stream for this month's transactions
    _firestoreService.getMonthlyTransactionsStream(monthKey, _currentUserId!).listen((
      monthlyTransactions,
    ) {
      double monthlyIncome = 0;
      double monthlyExpense = 0;

      List<TransactionEntry> transactionEntries = [];

      for (final tx in monthlyTransactions) {
        transactionEntries.add(TransactionEntry(tx.id, tx));
        if (tx.isIncome) {
          monthlyIncome += tx.amount;
        } else {
          monthlyExpense += tx.amount;
        }
      }

      _totalIncome = monthlyIncome;
      _totalExpense = monthlyExpense;
      _transactions = transactionEntries;

      if (!keepBalance) {
        // If not preserving balance, recalculate it based on all transactions up to the end of the selected month
        _recalculateBalanceForMonth(targetDate);
      } else {
        notifyListeners(); // If just updating monthly figures, notify listeners
      }
    });
  }

  // Recalculate balance up to a certain month
  void _recalculateBalanceForMonth(DateTime targetDate) {
    if (_currentUserId == null) return;

    // Get the last day of the selected month
    final endOfMonth = DateTime(targetDate.year, targetDate.month + 1, 0);

    _firestoreService
        .getTransactionsUpToDate(_currentUserId!, endOfMonth)
        .listen((transactions) {
          double newBalance = 0;
          for (final tx in transactions) {
            if (tx.isIncome) {
              newBalance += tx.amount;
            } else {
              newBalance -= tx.amount;
            }
          }
          _balance = newBalance;
          notifyListeners();
        });
  }

  // UPDATED: Add Income
  Future<void> addIncome(
    double amount,
    String category,
    String description,
    String wallet,
    String? cloudinaryImageUrl, {
    DateTime? date,
  }) async {
    if (_currentUserId == null) return;

    final transactionDate = date ?? DateTime.now();
    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: 'income',
      date: transactionDate,
      category: category,
      description: description,
      wallet: wallet,
      userId: _currentUserId!,
      receiptImageUrl: cloudinaryImageUrl,
    );

    await _firestoreService.addTransaction(tx, _currentUserId!);
    _loadInitialData(); // Reload all data
  }

  // UPDATED: Add Expense
  Future<void> addExpense(
    double amount,
    String category,
    String description,
    String wallet,
    String? cloudinaryImageUrl, {
    DateTime? date,
  }) async {
    if (_currentUserId == null) return;

    final transactionDate = date ?? DateTime.now();
    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: 'expense',
      date: transactionDate,
      category: category,
      description: description,
      wallet: wallet,
      userId: _currentUserId!,
      receiptImageUrl: cloudinaryImageUrl,
    );

    await _firestoreService.addTransaction(tx, _currentUserId!);
    _loadInitialData(); // Reload all data
  }

  // UPDATED: Edit Transaction
  Future<void> editTransaction(
    String transactionId,
    double newAmount,
    String newCategory,
    String newDescription,
    String newWallet,
    String? cloudinaryImageUrl, {
    DateTime? date,
  }) async {
    if (_currentUserId == null) return;

    final existingTransaction = await _firestoreService.getTransaction(
      transactionId,
      _currentUserId!,
    );
    if (existingTransaction == null) return;

    final updatedDate = date ?? existingTransaction.date;
    final updated = TransactionModel(
      id: transactionId,
      amount: newAmount,
      type: existingTransaction.type,
      date: updatedDate,
      category: newCategory,
      description: newDescription,
      wallet: newWallet,
      userId: _currentUserId!,
      receiptImageUrl: cloudinaryImageUrl,
    );

    await _firestoreService.updateTransaction(updated, _currentUserId!);
    _loadInitialData(); // Reload all data
  }

  // Delete Transaction
  Future<void> deleteTransaction(String transactionId) async {
    if (_currentUserId == null) return;
    await _firestoreService.deleteTransaction(transactionId, _currentUserId!);
    _loadInitialData(); // Reload all data
  }

  // Stream Methods
  Stream<List<TransactionModel>> getMonthlyTransactionsStream(String monthKey) {
    if (_currentUserId == null) return Stream.value([]);
    return _firestoreService.getMonthlyTransactionsStream(
      monthKey,
      _currentUserId!,
    );
  }

  Stream<List<TransactionModel>> getAllTransactionsStream() {
    if (_currentUserId == null) return Stream.value([]);
    return _firestoreService.getAllTransactionsStream(_currentUserId!);
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

  Stream<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (_currentUserId == null) return Stream.value([]);
    return _firestoreService.getTransactionsByDateRange(
      _currentUserId!,
      startDate,
      endDate,
    );
  }
}

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
