// services/auth_service.dart - UPDATED WITH USER DOCUMENT CREATION
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ADD THIS IMPORT
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // ADD THIS

  Stream<User?> get getCurrentUserStream => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ensure user document exists when signing in
      await _ensureUserDocumentExists(userCredential.user!, email);

      return userCredential.user;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<User?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // CREATE USER DOCUMENT IN FIRESTORE - THIS WAS MISSING!
      await _createUserDocument(userCredential.user!, email);

      return userCredential.user;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // CREATE USER DOCUMENT IN FIRESTORE
  Future<void> _createUserDocument(User user, String email) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ User document created for: $email (${user.uid})');
    } catch (e) {
      print('❌ Error creating user document: $e');
      // Don't throw here - we don't want signup to fail if document creation fails
    }
  }

  // ENSURE USER DOCUMENT EXISTS (for existing users)
  Future<void> _ensureUserDocumentExists(User user, String email) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        print('⚠️ User document missing, creating now...');
        await _createUserDocument(user, email);
      } else {
        print('✅ User document exists for: ${user.uid}');
      }
    } catch (e) {
      print('❌ Error checking user document: $e');
    }
  }

  // GET USER DATA FROM FIRESTORE
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
