// services/firestore_service.dart - Enhanced version
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_track/models/transaction_model.dart';

class FirestoreService {
  final CollectionReference _transactionsCollection = FirebaseFirestore.instance
      .collection('transactions');

  // Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _transactionsCollection
          .doc(transaction.id)
          .set(transaction.toMap());
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  // Update an existing transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _transactionsCollection
          .doc(transaction.id)
          .update(transaction.toMap());
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _transactionsCollection.doc(transactionId).delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  // Get a single transaction
  Future<TransactionModel?> getTransaction(String transactionId) async {
    try {
      final doc = await _transactionsCollection.doc(transactionId).get();
      if (doc.exists) {
        return TransactionModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }

  // Stream of last 10 transactions for home page
  Stream<List<TransactionModel>> getLast10TransactionsStream() {
    return _transactionsCollection
        .orderBy('date', descending: true)
        .limit(10)
        .snapshots()
        .handleError((error) => print("Firestore Error: $error"))
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => TransactionModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Stream of monthly transactions for history page
  Stream<List<TransactionModel>> getMonthlyTransactionsStream(
    String monthYear,
  ) {
    return _transactionsCollection
        .where('monthYear', isEqualTo: monthYear)
        .orderBy('date', descending: true)
        .snapshots()
        .handleError((error) => print("Firestore Error: $error"))
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => TransactionModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Stream of monthly summary for graphs
  Stream<Map<String, double>> getMonthlySummaryStream(String monthYear) {
    return _transactionsCollection
        .where('monthYear', isEqualTo: monthYear)
        .snapshots()
        .handleError((error) => print("Firestore Error: $error"))
        .map((snapshot) {
          double totalIncome = 0;
          double totalExpense = 0;

          for (final doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] ?? 0.0).toDouble();
            final isIncome = data['isIncome'] ?? false;

            if (isIncome) {
              totalIncome += amount;
            } else {
              totalExpense += amount;
            }
          }

          return {
            'totalIncome': totalIncome,
            'totalExpense': totalExpense,
            'balance': totalIncome - totalExpense,
          };
        });
  }

  // Stream of available months for filter dropdown
  Stream<List<String>> getAvailableMonthsStream() {
    return _transactionsCollection
        .orderBy('monthYear', descending: true)
        .snapshots()
        .handleError((error) => print("Firestore Error: $error"))
        .map((snapshot) {
          final months = snapshot.docs
              .map((doc) => doc['monthYear'] as String?)
              .where((month) => month != null)
              .cast<String>()
              .toSet()
              .toList();
          return months;
        });
  }
}
