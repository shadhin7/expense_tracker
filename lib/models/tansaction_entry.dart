// transaction_entry.dart
import 'package:expense_track/models/transaction_model.dart';

class TransactionEntry {
  final String key; // Changed from int to String for Firestore document IDs
  final TransactionModel transaction;

  TransactionEntry(this.key, this.transaction);
}
