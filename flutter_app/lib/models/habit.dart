/// Data model for a habit.
class Habit {
  final String id;
  final String title;
  final String description;
  final String category;
  final String frequency;
  final int targetCount;
  final bool isActive;
  final int completionCount;
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.frequency,
    required this.targetCount,
    required this.isActive,
    required this.completionCount,
    required this.createdAt,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      frequency: json['frequency'] as String? ?? 'daily',
      targetCount: json['target_count'] as int? ?? 1,
      isActive: json['is_active'] as bool? ?? true,
      completionCount: json['completion_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'frequency': frequency,
      'target_count': targetCount,
    };
  }

  static const List<String> categories = [
    'health',
    'productivity',
    'fitness',
    'mindfulness',
    'learning',
    'general',
  ];

  static const Map<String, String> categoryIcons = {
    'health': '❤️',
    'productivity': '⚡',
    'fitness': '💪',
    'mindfulness': '🧘',
    'learning': '📚',
    'general': '⭐',
  };
}
