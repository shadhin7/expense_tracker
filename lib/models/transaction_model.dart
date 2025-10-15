import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String type; // 'income' or 'expense'
  final DateTime date;
  final String category;
  final String description;
  final String wallet;
  final String monthYear;
  final String? receiptImageUrl; // ONLY CLOUDINARY URL

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
    required this.description,
    required this.wallet,
    this.receiptImageUrl, // ONLY Cloudinary URL
  }) : monthYear = '${date.year}-${date.month.toString().padLeft(2, '0')}';

  bool get isIncome => type.toLowerCase() == 'income';

  // ADD THIS: Expense checker
  bool get isExpense => type.toLowerCase() == 'expense';

  // UPDATED: Only Cloudinary URL, no local fallback
  String? get displayImage => receiptImageUrl;

  // UPDATED: Check only Cloudinary URL
  bool get hasImage => receiptImageUrl != null && receiptImageUrl!.isNotEmpty;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type,
      'date': Timestamp.fromDate(date),
      'category': category,
      'description': description,
      'wallet': wallet,
      'monthYear': monthYear,
      'isIncome': isIncome,
      'isExpense': isExpense, // ADD THIS
      'receiptImageUrl': receiptImageUrl, // ONLY Cloudinary URL
      // REMOVED: localImagePath
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document
  factory TransactionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return TransactionModel(
      id: documentId,
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: map['type'] ?? '',
      date: _parseDate(map['date']),
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      wallet: map['wallet'] ?? '',
      receiptImageUrl: map['receiptImageUrl'], // ONLY Cloudinary URL
      // REMOVED: localImagePath
    );
  }

  static DateTime _parseDate(dynamic dateField) {
    if (dateField is Timestamp) {
      return dateField.toDate();
    } else if (dateField is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateField);
    } else {
      return DateTime.now();
    }
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? type,
    DateTime? date,
    String? category,
    String? description,
    String? wallet,
    String? receiptImageUrl,
    // REMOVED: localImagePath
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      category: category ?? this.category,
      description: description ?? this.description,
      wallet: wallet ?? this.wallet,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      // REMOVED: localImagePath
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, amount: $amount, type: $type, cloudImage: $receiptImageUrl)';
  }
}
