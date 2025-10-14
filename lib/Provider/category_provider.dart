import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryProvider with ChangeNotifier {
  List<String> _categories = [];
  final _firestore = FirebaseFirestore.instance;

  List<String> get categories => _categories;

  /// Get current user ID
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  /// Load categories for this user
  Future<void> loadCategories() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .get();

    _categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
    notifyListeners();
  }

  /// Add new category for this user
  Future<void> addCategory(String category) async {
    if (!_categories.contains(category)) {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('categories')
          .add({'name': category});
      _categories.add(category);
      notifyListeners();
    }
  }

  /// Delete category for this user
  Future<void> deleteCategory(String category) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .where('name', isEqualTo: category)
        .get();

    for (var doc in snapshot.docs) {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('categories')
          .doc(doc.id)
          .delete();
    }

    _categories.remove(category);
    notifyListeners();
  }
}
