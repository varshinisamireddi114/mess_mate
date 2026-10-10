
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/mess_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please log in.'));
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: MessService().getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = snapshot.data ?? {};

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFFE0F2E9),
              child: Icon(
                Icons.person,
                size: 55,
                color: Color(0xFF16856B),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              profile['name'] as String? ?? 'Student',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              user.email ?? '',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Card(
              child: ListTile(
                leading: const Icon(Icons.verified_user_outlined),
                title: const Text('Account type'),
                subtitle: Text(
                  profile['role'] as String? ?? 'student',
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(user.email ?? 'Not available'),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                await AuthService().logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
