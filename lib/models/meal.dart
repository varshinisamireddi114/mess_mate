
class Meal {
  final String id;
  final String day;
  final String meal;
  final String items;
  final String? time;

  const Meal({
    required this.id,
    required this.day,
    required this.meal,
    required this.items,
    this.time,
  });

  factory Meal.fromMap(String id, Map<String, dynamic> data) {
    return Meal(
      id: id,
      day: data['day'] as String? ?? '',
      meal: data['meal'] as String? ?? '',
      items: data['items'] as String? ?? '',
      time: data['time'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'meal': meal,
      'items': items,
      'time': time,
    };
  }
}
