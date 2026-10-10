
import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meals = [
      {
        'name': 'Breakfast',
        'time': '7:30 AM – 9:00 AM',
        'items': 'Idli, Dosa, Upma, Tea',
        'icon': Icons.free_breakfast,
      },
      {
        'name': 'Lunch',
        'time': '12:00 PM – 2:00 PM',
        'items': 'Rice, Dal, Curry, Sambar, Curd',
        'icon': Icons.lunch_dining,
      },
      {
        'name': 'Snacks',
        'time': '4:30 PM – 5:30 PM',
        'items': 'Tea, Biscuits, Snacks',
        'icon': Icons.bakery_dining,
      },
      {
        'name': 'Dinner',
        'time': '7:00 PM – 9:00 PM',
        'items': 'Rice, Chapati, Curry, Dal',
        'icon': Icons.dinner_dining,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Today's Menu 🍽️",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Check out what is being served today.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        ...meals.map((meal) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    meal['icon'] as IconData,
                    size: 36,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal['name'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meal['time'] as String,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(meal['items'] as String),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
