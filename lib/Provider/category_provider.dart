import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_track/services/category_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _service = CategoryService();
  List<String> _expenseCategories = [];
  List<String> _incomeCategories = [];

  List<String> get expenseCategories => _expenseCategories;
  List<String> get incomeCategories => _incomeCategories;

  Future<void> loadUserCategories(String type) async {
    final categories = await _service.getUserCategories(type);
    if (type == 'expense') {
      _expenseCategories = categories;
    } else {
      _incomeCategories = categories;
    }
    notifyListeners();
  }

  Future<void> addUserCategory(String name, String type) async {
    await _service.addUserCategory(name, type);
    if (type == 'expense') {
      _expenseCategories.add(name);
    } else {
      _incomeCategories.add(name);
    }
    notifyListeners();
  }

  Future<void> deleteUserCategory(String name, String type) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('categories');

    final snapshot = await collection
        .where('name', isEqualTo: name)
        .where('type', isEqualTo: type)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    // Update local state
    if (type == 'expense') {
      _expenseCategories.remove(name);
    } else {
      _incomeCategories.remove(name);
    }

    notifyListeners();
  }
}
