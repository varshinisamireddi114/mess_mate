
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/meal.dart';

class MessService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _menus =>
      _db.collection('menus');

  CollectionReference<Map<String, dynamic>> get _grievances =>
      _db.collection('grievances');

  // ---------------- MENU MANAGEMENT ----------------

  Stream<List<Meal>> watchMenus() {
    return _menus.snapshots().map((snapshot) {
      final meals = snapshot.docs
          .map((doc) => Meal.fromMap(doc.id, doc.data()))
          .toList();

      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];

      const mealOrder = [
        'Breakfast',
        'Lunch',
        'Snacks',
        'Dinner',
      ];

      meals.sort((a, b) {
        final dayCompare =
            days.indexOf(a.day).compareTo(days.indexOf(b.day));

        if (dayCompare != 0) return dayCompare;

        return mealOrder
            .indexOf(a.meal)
            .compareTo(mealOrder.indexOf(b.meal));
      });

      return meals;
    });
  }

  Future<void> addMenu(Meal meal) async {
    await _menus.add({
      ...meal.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update an existing menu item.
  Future<void> updateMenu(Meal meal) async {
    if (meal.id.isEmpty) {
      throw Exception('Menu ID is missing.');
    }

    await _menus.doc(meal.id).update({
      ...meal.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteMenu(String id) async {
    await _menus.doc(id).delete();
  }

  // ---------------- STUDENT FEEDBACK ----------------

  Future<void> submitFeedback({
    required double rating,
    required String message,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please log in first.');
    }

    if (message.trim().isEmpty) {
      throw Exception('Please enter your feedback.');
    }

    await _db.collection('feedback').add({
      'uid': user.uid,
      'email': user.email ?? '',
      'rating': rating,
      'message': message.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchFeedback() {
    return _db.collection('feedback').snapshots();
  }

  // ---------------- GRIEVANCE MANAGEMENT ----------------

  // Students submit grievances using this method.
  Future<void> submitGrievance({
    required String title,
    required String description,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please log in first.');
    }

    if (title.trim().isEmpty || description.trim().isEmpty) {
      throw Exception('Enter both a title and description.');
    }

    await _grievances.add({
      'uid': user.uid,
      'email': user.email ?? '',
      'title': title.trim(),
      'description': description.trim(),
      'status': 'Yet to be Resolved',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Admin receives live updates when students submit grievances.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchGrievances() {
    return _grievances.snapshots();
  }

  // Students can listen to their own grievances.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyGrievances() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please log in first.');
    }

    return _grievances
        .where('uid', isEqualTo: user.uid)
        .snapshots();
  }

  // Admin updates the status of a grievance.
  Future<void> updateGrievanceStatus({
    required String grievanceId,
    required String status,
  }) async {
    const allowedStatuses = [
      'Yet to be Resolved',
      'Resolved',
    ];

    if (!allowedStatuses.contains(status)) {
      throw Exception('Invalid grievance status.');
    }

    await _grievances.doc(grievanceId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------- USER PROFILE ----------------

  Future<Map<String, dynamic>?> getProfile() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final snapshot =
        await _db.collection('users').doc(user.uid).get();

    return snapshot.data();
  }
}
