import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  final DateTime? createdAt;

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
    this.createdAt,
  }) : monthYear = '${date.year}-${date.month.toString().padLeft(2, '0')}';

  bool get isIncome => type.toLowerCase() == 'income';

  // Expense checker
  bool get isExpense => type.toLowerCase() == 'expense';

  // ONLY Cloudinary URL - no local fallback
  String? get displayImage => receiptImageUrl;

  // Check only Cloudinary URL
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
      'isExpense': isExpense,
      'receiptImageUrl': receiptImageUrl, // ONLY Cloudinary URL
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document - FIXED VERSION
  factory TransactionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return TransactionModel(
      id: documentId,
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: map['type'] ?? '',
      date: _parseDate(map['date']) ?? DateTime.now(),
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      wallet: map['wallet'] ?? '',
      receiptImageUrl: map['receiptImageUrl'], // ONLY Cloudinary URL
      createdAt: _parseDate(map['createdAt']),
    );
  }

  static DateTime? _parseDate(dynamic dateField) {
    if (dateField == null) return null;

    try {
      if (dateField is Timestamp) {
        return dateField.toDate();
      } else if (dateField is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateField);
      } else if (dateField is String) {
        return DateTime.tryParse(dateField);
      } else {
        return null;
      }
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  // NEW: Helper method to format date for display
  String get formattedDisplayDate {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // NEW: Helper method to check if date is in current month
  bool get isInCurrentMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
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
    DateTime? createdAt,
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
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, amount: $amount, type: $type, category: $category, date: $formattedDisplayDate, cloudImage: $receiptImageUrl)';
  }

  // Helper method to check if this is a valid transaction
  bool get isValid {
    return id.isNotEmpty &&
        userId.isNotEmpty &&
        amount > 0 &&
        type.isNotEmpty &&
        category.isNotEmpty &&
        wallet.isNotEmpty;
  }

  // Helper method for display
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method for amount display
  String get formattedAmountWithoutCurrency {
    return amount.toStringAsFixed(2);
  }
}
