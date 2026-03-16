/// Data model for AI-generated habit insights.
class HabitInsight {
  final String habitId;
  final String habitTitle;
  final int streak;
  final double completionRate;
  final String suggestion;
  final String motivationLevel;

  HabitInsight({
    required this.habitId,
    required this.habitTitle,
    required this.streak,
    required this.completionRate,
    required this.suggestion,
    required this.motivationLevel,
  });

  factory HabitInsight.fromJson(Map<String, dynamic> json) {
    return HabitInsight(
      habitId: json['habit_id'] as String,
      habitTitle: json['habit_title'] as String,
      streak: json['streak'] as int? ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      suggestion: json['suggestion'] as String? ?? '',
      motivationLevel: json['motivation_level'] as String? ?? 'medium',
    );
  }
}

/// Aggregated dashboard data from the backend.
class Dashboard {
  final int totalHabits;
  final int activeHabits;
  final int totalCompletionsToday;
  final int overallStreak;
  final String topCategory;
  final List<HabitInsight> insights;

  Dashboard({
    required this.totalHabits,
    required this.activeHabits,
    required this.totalCompletionsToday,
    required this.overallStreak,
    required this.topCategory,
    required this.insights,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      totalHabits: json['total_habits'] as int? ?? 0,
      activeHabits: json['active_habits'] as int? ?? 0,
      totalCompletionsToday: json['total_completions_today'] as int? ?? 0,
      overallStreak: json['overall_streak'] as int? ?? 0,
      topCategory: json['top_category'] as String? ?? 'none',
      insights: (json['insights'] as List<dynamic>?)
              ?.map((e) => HabitInsight.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
