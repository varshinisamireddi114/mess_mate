
import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/auth_service.dart';
import '../services/mess_service.dart';
import '../widgets/meal_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _service = MessService();
  final _formKey = GlobalKey<FormState>();

  final _items = TextEditingController();
  final _time = TextEditingController();

  String _day = 'Monday';
  String _meal = 'Breakfast';
  bool _saving = false;
  Meal? _editingMeal;

  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const _meals = [
    'Breakfast',
    'Lunch',
    'Snacks',
    'Dinner',
  ];

  @override
  void dispose() {
    _items.dispose();
    _time.dispose();
    super.dispose();
  }

  void _startEditing(Meal meal) {
    setState(() {
      _editingMeal = meal;
      _day = meal.day;
      _meal = meal.meal;
      _items.text = meal.items;
      _time.text = meal.time ?? '';
    });

    _formKey.currentState?.reset();
  }

  void _cancelEditing() {
    setState(() {
      _editingMeal = null;
      _day = 'Monday';
      _meal = 'Breakfast';
      _items.clear();
      _time.clear();
    });
  }

  Future<void> _saveMenu() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final menu = Meal(
        id: _editingMeal?.id ?? '',
        day: _day,
        meal: _meal,
        items: _items.text.trim(),
        time: _time.text.trim().isEmpty
            ? null
            : _time.text.trim(),
      );

      if (_editingMeal == null) {
        await _service.addMenu(menu);
      } else {
        await _service.updateMenu(menu);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingMeal == null
                ? 'Menu added successfully!'
                : 'Menu updated successfully!',
          ),
        ),
      );

      _cancelEditing();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save menu: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteMenu(Meal meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete menu?'),
        content: Text('Delete ${meal.day} ${meal.meal}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.deleteMenu(meal.id);

      if (_editingMeal?.id == meal.id) {
        _cancelEditing();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu deleted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete menu: $e')),
        );
      }
    }
  }

  Future<void> _updateGrievance(
    String id,
    String status,
  ) async {
    try {
      await _service.updateGrievanceStatus(
        grievanceId: id,
        status: status,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grievance status updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update status: $e')),
        );
      }
    }
  }

  Widget _buildGrievances() {
    return StreamBuilder(
      stream: _service.watchGrievances(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Could not load grievances. Check Firestore permissions.',
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs.toList();

        docs.sort((a, b) {
          final aTime = a.data()['createdAt'] as dynamic;
          final bTime = b.data()['createdAt'] as dynamic;

          final aDate = aTime is DateTime
              ? aTime
              : aTime is Timestamp
                  ? aTime.toDate()
                  : DateTime.fromMillisecondsSinceEpoch(0);

          final bDate = bTime is DateTime
              ? bTime
              : bTime is Timestamp
                  ? bTime.toDate()
                  : DateTime.fromMillisecondsSinceEpoch(0);

          return bDate.compareTo(aDate);
        });

        if (docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No student grievances submitted yet.'),
            ),
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data();
            final status =
                data['status'] as String? ?? 'Yet to be Resolved';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] as String? ?? 'Untitled grievance',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data['description'] as String? ?? '',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Student: ${data['email'] ?? 'Unknown'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: status,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Grievance Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Yet to be Resolved',
                          child: Text('Yet to be Resolved'),
                        ),
                        DropdownMenuItem(
                          value: 'Resolved',
                          child: Text('Resolved'),
                        ),
                      ],
                      onChanged: status == 'Yet to be Resolved' ||
                              status == 'Resolved'
                          ? (value) {
                              if (value != null && value != status) {
                                _updateGrievance(doc.id, value);
                              }
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mess Mate Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => AuthService().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Manage Food Menu',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _day,
                      decoration: const InputDecoration(labelText: 'Day'),
                      items: _days.map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text(day),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _day = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _meal,
                      decoration: const InputDecoration(labelText: 'Meal'),
                      items: _meals.map((meal) {
                        return DropdownMenuItem(
                          value: meal,
                          child: Text(meal),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _meal = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _items,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Food items',
                        hintText: 'Idli, sambar, chutney...',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Enter the food items'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _time,
                      decoration: const InputDecoration(
                        labelText: 'Meal timing (optional)',
                        hintText: '7:00 AM - 9:00 AM',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _saving ? null : _saveMenu,
                      icon: Icon(
                        _editingMeal == null ? Icons.add : Icons.save,
                      ),
                      label: Text(
                        _saving
                            ? 'Saving...'
                            : _editingMeal == null
                                ? 'Add Menu'
                                : 'Update Menu',
                      ),
                    ),
                    if (_editingMeal != null) ...[
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _saving ? null : _cancelEditing,
                        child: const Text('Cancel Editing'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Existing Menu',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Meal>>(
            stream: _service.watchMenus(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Could not load the menu.');
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.isEmpty) {
                return const Text('No menu items have been added.');
              }

              return Column(
                children: snapshot.data!.map((meal) {
                  return Column(
                    children: [
                      MealCard(
                        meal: meal,
                        onDelete: () => _deleteMenu(meal),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _startEditing(meal),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Menu'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Student Grievances',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildGrievances(),
          const SizedBox(height: 24),
          const Text(
            'Student Feedback',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          StreamBuilder(
            stream: _service.watchFeedback(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Could not load student feedback.');
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final feedbackDocs = snapshot.data!.docs;

              if (feedbackDocs.isEmpty) {
                return const Text('No feedback submitted yet.');
              }

              return Column(
                children: feedbackDocs.map((doc) {
                  final data = doc.data();

                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      title: Text(data['message'] as String? ?? ''),
                      subtitle: Text(
                        '${data['email'] ?? 'Student'} • '
                        '${data['rating'] ?? '-'} / 5 stars',
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
