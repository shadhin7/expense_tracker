// transaction_model.dart
// Remove Hive imports and annotations

import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String? id; // Added for Firestore document ID
  double amount;
  String type;
  DateTime date;
  String category;
  String description;
  String wallet;
  String? imagePath;
  String monthYear; // Added for monthly filtering

  TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
    required this.description,
    required this.wallet,
    this.imagePath,
  }) : monthYear = '${date.year}-${date.month.toString().padLeft(2, '0')}';

  bool get isIncome => type.toLowerCase() == 'income';

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'type': type,
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'description': description,
      'wallet': wallet,
      'imagePath': imagePath,
      'monthYear': monthYear,
      'isIncome': isIncome,
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
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: map['type'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      wallet: map['wallet'] ?? '',
      imagePath: map['imagePath'],
    );
  }

  // Copy with method for editing
  TransactionModel copyWith({
    String? id,
    double? amount,
    String? type,
    DateTime? date,
    String? category,
    String? description,
    String? wallet,
    String? imagePath,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      category: category ?? this.category,
      description: description ?? this.description,
      wallet: wallet ?? this.wallet,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
