
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  String _selectedRole = '';
  bool _register = false;
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      _register = false;
      _name.clear();
      _email.clear();
      _password.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      if (_register) {
        await _authService.register(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student account created successfully!'),
            ),
          );
        }
      } else {
        await _authService.login(
          email: _email.text.trim(),
          password: _password.text,
          expectedRole: _selectedRole,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _errorMessage(Object error) {
    final text = error.toString();

    if (text.contains('email-already-in-use')) {
      return 'This email is already registered.';
    }
    if (text.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    if (text.contains('weak-password')) {
      return 'Choose a stronger password.';
    }
    if (text.contains('user-not-found') ||
        text.contains('wrong-password') ||
        text.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    }
    if (text.contains('not authorized for admin login')) {
      return 'This account is not authorized for Admin Login.';
    }
    if (text.contains('use Admin Login')) {
      return 'Please use Admin Login for this account.';
    }
    if (text.contains('User profile not found')) {
      return 'Account profile not found. Contact the administrator.';
    }
    if (text.contains('permission-denied')) {
      return 'Access denied. Check your Firebase permissions.';
    }

    return 'Unable to continue. Please check your connection and Firebase setup.';
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = _selectedRole == 'student';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: _selectedRole.isEmpty
                  ? _buildRoleSelection()
                  : _buildLoginForm(isStudent),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.restaurant,
          size: 78,
          color: Color(0xFF16856B),
        ),
        const SizedBox(height: 12),
        const Text(
          'Mess Mate',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your mess, made easier.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        FilledButton.icon(
          onPressed: () => _selectRole('admin'),
          icon: const Icon(Icons.admin_panel_settings),
          label: const Padding(
            padding: EdgeInsets.all(14),
            child: Text('Admin Login'),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _selectRole('student'),
          icon: const Icon(Icons.school),
          label: const Padding(
            padding: EdgeInsets.all(14),
            child: Text('Student Login / Register'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(bool isStudent) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            isStudent
                ? Icons.school_outlined
                : Icons.admin_panel_settings_outlined,
            size: 72,
            color: const Color(0xFF16856B),
          ),
          const SizedBox(height: 12),
          const Text(
            'Mess Mate',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isStudent ? 'Student Portal' : 'Admin Portal',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 28),
          Text(
            _register ? 'Create student account' : 'Welcome back!',
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          if (_register) ...[
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Enter your name'
                      : null,
            ),
            const SizedBox(height: 14),
          ],
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || !value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _password,
            obscureText: _hidePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _hidePassword = !_hidePassword);
                },
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Password must contain at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _loading
                    ? 'Please wait...'
                    : _register
                        ? 'Create Student Account'
                        : 'Login as ${isStudent ? 'Student' : 'Admin'}',
              ),
            ),
          ),
          if (isStudent)
            TextButton(
              onPressed: _loading
                  ? null
                  : () {
                      setState(() => _register = !_register);
                    },
              child: Text(
                _register
                    ? 'Already registered? Login'
                    : 'New student? Register here',
              ),
            ),
          TextButton(
            onPressed: _loading ? null : () => _selectRole(''),
            child: const Text('← Back to role selection'),
          ),
        ],
      ),
    );
  }
}
