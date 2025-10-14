// services/firestore_service.dart - UPDATED FOR PER-USER DATA
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_track/models/transaction_model.dart';

class FirestoreService {
  // No need to store collection reference separately since we'll use it with queries

  // Add a new transaction - UPDATED
  Future<void> addTransaction(
    TransactionModel transaction,
    String userId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toMap());
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  // Update an existing transaction - UPDATED
  Future<void> updateTransaction(
    TransactionModel transaction,
    String userId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toMap());
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  // Delete a transaction - UPDATED
  Future<void> deleteTransaction(String transactionId, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  // Get a single transaction - UPDATED
  Future<TransactionModel?> getTransaction(
    String transactionId,
    String userId,
  ) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionId)
          .get();

      if (doc.exists) {
        final transaction = TransactionModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        // Optional: Verify the transaction belongs to the current user
        if (transaction.userId == userId) {
          return transaction;
        }
        return null;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }

  // Stream of last 10 transactions for home page - UPDATED
  Stream<List<TransactionModel>> getLast10TransactionsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId) // ADD THIS FILTER
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

  // Stream of monthly transactions for history page - UPDATED
  Stream<List<TransactionModel>> getMonthlyTransactionsStream(
    String monthYear,
    String userId,
  ) {
    return FirebaseFirestore.instance
        .collection('transactions')
        .where('monthYear', isEqualTo: monthYear)
        .where('userId', isEqualTo: userId) // ADD THIS FILTER
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

  // Stream of monthly summary for graphs - UPDATED
  Stream<Map<String, double>> getMonthlySummaryStream(
    String monthYear,
    String userId,
  ) {
    return FirebaseFirestore.instance
        .collection('transactions')
        .where('monthYear', isEqualTo: monthYear)
        .where('userId', isEqualTo: userId) // ADD THIS FILTER
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

  // Stream of available months for filter dropdown - UPDATED
  Stream<List<String>> getAvailableMonthsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId) // ADD THIS FILTER
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
