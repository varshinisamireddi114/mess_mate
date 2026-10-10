
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    try {
      await _db.collection('users').doc(credential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
  }

  Future<String> login({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    try {
      final user = credential.user!;

      final snapshot =
          await _db.collection('users').doc(user.uid).get();

      if (!snapshot.exists) {
        throw Exception('User profile not found.');
      }

      final role = snapshot.data()?['role'] as String?;

      if (role != expectedRole) {
        throw Exception(
          expectedRole == 'admin'
              ? 'This account is not authorized for admin login.'
              : 'Please use Admin Login for this account.',
        );
      }

      return role!;
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
  }

  Future<String?> getCurrentRole() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final snapshot =
        await _db.collection('users').doc(user.uid).get();

    if (!snapshot.exists) return null;

    return snapshot.data()?['role'] as String?;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
