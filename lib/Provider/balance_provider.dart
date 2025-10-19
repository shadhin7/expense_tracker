// balance_provider.dart - UPDATED WITH CUSTOM DATE SUPPORT
import 'package:expense_track/models/tansaction_entry.dart';
import 'package:expense_track/models/transaction_model.dart';
import 'package:expense_track/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/cloudinary_service.dart';

class BalanceProvider with ChangeNotifier {
  double _balance = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;
  List<TransactionEntry> _transactions = [];
  String? _currentUserId;
  bool _isUploadingImage = false;

  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  double get balance => _balance;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  List<TransactionEntry> get transactions => _transactions;
  bool get isUploadingImage => _isUploadingImage;

  String get formattedBalance => _balance.toStringAsFixed(2);
  String get formattedTotalIncome => _totalIncome.toStringAsFixed(2);
  String get formattedTotalExpense => _totalExpense.toStringAsFixed(2);

  BalanceProvider() {
    _initializeUserData();
  }

  // Initialize with user data
  void _initializeUserData() {
    // Set user from Firebase Auth if available
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      _loadCurrentMonthData();
    }
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
    _isUploadingImage = false;
    notifyListeners();
  }

  String _getMonthKey(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  // Get current user ID
  String? get currentUserId => _currentUserId;

  // UPDATED: Take photo with camera and upload to Cloudinary (ONLY CLOUD)
  Future<String?> takePhotoAndUpload() async {
    if (_currentUserId == null) return null;

    try {
      _setUploadingState(true);

      String transactionId = DateTime.now().millisecondsSinceEpoch.toString();
      String? cloudinaryUrl = await _cloudinaryService.takePhotoAndUpload(
        userId: _currentUserId!,
        transactionId: transactionId,
      );

      return cloudinaryUrl; // This is the Cloudinary URL
    } catch (e) {
      print('Error taking and uploading photo: $e');
      return null;
    } finally {
      _setUploadingState(false);
    }
  }

  // UPDATED: Pick from gallery and upload to Cloudinary (ONLY CLOUD)
  Future<String?> pickFromGalleryAndUpload() async {
    if (_currentUserId == null) return null;

    try {
      _setUploadingState(true);

      String transactionId = DateTime.now().millisecondsSinceEpoch.toString();
      String? cloudinaryUrl = await _cloudinaryService.pickFromGalleryAndUpload(
        userId: _currentUserId!,
        transactionId: transactionId,
      );

      return cloudinaryUrl; // This is the Cloudinary URL
    } catch (e) {
      print('Error picking and uploading from gallery: $e');
      return null;
    } finally {
      _setUploadingState(false);
    }
  }

  // UPDATED: Add Income with custom date support
  Future<void> addIncome(
    double amount,
    String category,
    String description,
    String wallet,
    String? cloudinaryImageUrl, {
    DateTime? date, // NEW: Optional custom date parameter
  }) async {
    if (_currentUserId == null) return;

    // Use custom date if provided, otherwise use current date
    final transactionDate = date ?? DateTime.now();

    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: 'income',
      date: transactionDate, // Use the selected date
      category: category,
      description: description,
      wallet: wallet,
      userId: _currentUserId!,
      receiptImageUrl: cloudinaryImageUrl,
    );

    await _firestoreService.addTransaction(tx, _currentUserId!);

    // Only update local state if transaction is in current month
    if (_getMonthKey(tx.date) == _getMonthKey(DateTime.now())) {
      _transactions.add(TransactionEntry(tx.id, tx));
      _balance += tx.amount;
      _totalIncome += tx.amount;
      notifyListeners();
    }
  }

  // UPDATED: Add Expense with custom date support
  Future<void> addExpense(
    double amount,
    String category,
    String description,
    String wallet,
    String? cloudinaryImageUrl, {
    DateTime? date, // NEW: Optional custom date parameter
  }) async {
    if (_currentUserId == null) return;

    // Use custom date if provided, otherwise use current date
    final transactionDate = date ?? DateTime.now();

    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: 'expense',
      date: transactionDate, // Use the selected date
      category: category,
      description: description,
      wallet: wallet,
      userId: _currentUserId!,
      receiptImageUrl: cloudinaryImageUrl,
    );

    await _firestoreService.addTransaction(tx, _currentUserId!);

    // Only update local state if transaction is in current month
    if (_getMonthKey(tx.date) == _getMonthKey(DateTime.now())) {
      _transactions.add(TransactionEntry(tx.id, tx));
      _balance -= tx.amount;
      _totalExpense += tx.amount;
      notifyListeners();
    }
  }

  // UPDATED: Edit Transaction with Cloudinary support only
  Future<void> editTransaction(
    String transactionId,
    double newAmount,
    String newCategory,
    String newDescription,
    String newWallet,
    String? cloudinaryImageUrl, {
    DateTime? date, // NEW: Optional custom date parameter for editing
  }) async {
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

    // Use custom date if provided, otherwise keep existing date
    final updatedDate = date ?? existingTransaction.date;

    // Create updated transaction
    final updated = TransactionModel(
      id: transactionId,
      amount: newAmount,
      type: existingTransaction.type,
      date: updatedDate, // Use updated date
      category: newCategory,
      description: newDescription,
      wallet: newWallet,
      userId: _currentUserId!,
      receiptImageUrl: cloudinaryImageUrl,
    );

    await _firestoreService.updateTransaction(updated, _currentUserId!);

    // Check if updated transaction is in current month
    final isUpdatedInCurrentMonth =
        _getMonthKey(updatedDate) == _getMonthKey(DateTime.now());

    if (isUpdatedInCurrentMonth) {
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
      } else {
        // Add to local list if it wasn't there before
        _transactions.add(TransactionEntry(transactionId, updated));
      }
    } else {
      // Remove from local list if it's no longer in current month
      _transactions.removeWhere((entry) => entry.key == transactionId);
    }

    notifyListeners();
  }

  // NEW: Update transaction receipt URL
  Future<void> updateTransactionReceipt(
    String transactionId,
    String? receiptImageUrl, // Can be null to remove receipt
  ) async {
    if (_currentUserId == null) return;

    try {
      // First, get the existing transaction
      final existingTransaction = await _firestoreService.getTransaction(
        transactionId,
        _currentUserId!,
      );

      if (existingTransaction == null) return;

      // Create updated transaction with new receipt URL
      final updated = TransactionModel(
        id: transactionId,
        amount: existingTransaction.amount,
        type: existingTransaction.type,
        date: existingTransaction.date,
        category: existingTransaction.category,
        description: existingTransaction.description,
        wallet: existingTransaction.wallet,
        userId: _currentUserId!,
        receiptImageUrl: receiptImageUrl, // Updated Cloudinary URL
      );

      // Update in Firestore
      await _firestoreService.updateTransaction(updated, _currentUserId!);

      // Update in local state if it's in current month
      final isCurrentMonth =
          _getMonthKey(existingTransaction.date) ==
          _getMonthKey(DateTime.now());

      if (isCurrentMonth) {
        final index = _transactions.indexWhere(
          (entry) => entry.key == transactionId,
        );
        if (index != -1) {
          _transactions[index] = TransactionEntry(transactionId, updated);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating transaction receipt: $e');
      throw Exception('Failed to update receipt: $e');
    }
  }

  // Helper method
  void _setUploadingState(bool uploading) {
    _isUploadingImage = uploading;
    notifyListeners();
  }

  // Delete Transaction with Firestore
  Future<void> deleteTransaction(String transactionId) async {
    if (_currentUserId == null) return;
    await _firestoreService.deleteTransaction(transactionId, _currentUserId!);
    _loadCurrentMonthData();
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
            _transactions.add(TransactionEntry(tx.id, tx));
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

  // NEW: Get transactions for a specific date range
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

// Month picker
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
