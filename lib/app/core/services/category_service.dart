import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> addUserCategory(String name, String type) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .add({
          'name': name,
          'type': type, // 'expense' or 'income'
        });
  }

  Future<List<String>> getUserCategories(String type) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .where('type', isEqualTo: type)
        .get();

    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }
}
