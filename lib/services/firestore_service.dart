// services/firestore_service.dart - FIXED VERSION
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_track/models/transaction_model.dart';

class FirestoreService {
  // Add a new transaction - FIXED
  Future<void> addTransaction(
    TransactionModel transaction,
    String userId,
  ) async {
    try {
      print('➕ FirestoreService: Adding transaction for user $userId');
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toMap());
      print('✅ FirestoreService: Transaction added successfully');
    } catch (e) {
      print('❌ FirestoreService: Failed to add transaction: $e');
      throw Exception('Failed to add transaction: $e');
    }
  }

  // Update an existing transaction
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

  // Delete a transaction
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

  // Get a single transaction
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

  // Stream of last 10 transactions for home page - FIXED
  Stream<List<TransactionModel>> getLast10TransactionsStream(String userId) {
    print('🔍 FirestoreService: Getting last 10 transactions for user $userId');

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(10)
        .snapshots()
        .handleError((error) {
          print('❌ FirestoreService Error (last10): $error');
          return Stream<List<TransactionModel>>.value(
            [],
          ); // Return empty list on error
        })
        .map((snapshot) {
          final transactions = snapshot.docs
              .map((doc) {
                try {
                  return TransactionModel.fromMap(
                    doc.data(), // Added type cast
                    doc.id,
                  );
                } catch (e) {
                  print('❌ Error parsing transaction ${doc.id}: $e');
                  return null;
                }
              })
              .where((transaction) => transaction != null)
              .cast<TransactionModel>()
              .toList();

          print(
            '📄 FirestoreService: Last 10 transactions: ${transactions.length}',
          );
          return transactions;
        });
  }

  // Stream of monthly transactions for history page - FIXED
  Stream<List<TransactionModel>> getMonthlyTransactionsStream(
    String monthYear,
    String userId,
  ) {
    print(
      '🔍 FirestoreService: Getting monthly transactions for $monthYear, user $userId',
    );

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('monthYear', isEqualTo: monthYear)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .handleError((error) {
          print('❌ FirestoreService Error (monthly): $error');
          return Stream<List<TransactionModel>>.value(
            [],
          ); // Return empty list on error
        })
        .map((snapshot) {
          final transactions = snapshot.docs
              .map((doc) {
                try {
                  return TransactionModel.fromMap(
                    doc.data(), // Added type cast
                    doc.id,
                  );
                } catch (e) {
                  print('❌ Error parsing transaction ${doc.id}: $e');
                  return null;
                }
              })
              .where((transaction) => transaction != null)
              .cast<TransactionModel>()
              .toList();

          print(
            '📄 FirestoreService: Monthly transactions for $monthYear: ${transactions.length}',
          );
          return transactions;
        });
  }

  // Stream of monthly summary for graphs - FIXED
  Stream<Map<String, double>> getMonthlySummaryStream(
    String monthYear,
    String userId,
  ) {
    print(
      '🔍 FirestoreService: Getting monthly summary for $monthYear, user $userId',
    );

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('monthYear', isEqualTo: monthYear)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .handleError((error) {
          print('❌ FirestoreService Error (summary): $error');
          return Stream<Map<String, double>>.value({
            // Return empty map on error
            'totalIncome': 0.0,
            'totalExpense': 0.0,
            'balance': 0.0,
          });
        })
        .map((snapshot) {
          double totalIncome = 0;
          double totalExpense = 0;

          for (final doc in snapshot.docs) {
            final data = doc.data(); // Added type cast
            final amount = (data['amount'] ?? 0.0).toDouble();
            final isIncome = data['isIncome'] ?? false;

            if (isIncome) {
              totalIncome += amount;
            } else {
              totalExpense += amount;
            }
          }

          print(
            '💰 FirestoreService: Monthly summary - Income: $totalIncome, Expense: $totalExpense',
          );
          return {
            'totalIncome': totalIncome,
            'totalExpense': totalExpense,
            'balance': totalIncome - totalExpense,
          };
        });
  }

  // Stream of available months for filter dropdown - FIXED
  Stream<List<String>> getAvailableMonthsStream(String userId) {
    print('🔍 FirestoreService: Getting available months for user $userId');

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('monthYear', descending: true)
        .snapshots()
        .handleError((error) {
          print('❌ FirestoreService Error (months): $error');
          return Stream<List<String>>.value([]); // Return empty list on error
        })
        .map((snapshot) {
          final months = snapshot.docs
              .map(
                (doc) => (doc.data())['monthYear'] as String?,
              ) // Added type cast
              .where((month) => month != null)
              .cast<String>()
              .toSet()
              .toList();

          print('📅 FirestoreService: Available months: ${months.length}');
          return months;
        });
  }
}
