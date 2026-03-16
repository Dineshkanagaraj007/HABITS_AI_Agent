import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.dashboard == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final dash = provider.dashboard;
        if (dash == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rocket_launch, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Start your journey!', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Add your first habit to see insights here.',
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.fetchDashboard();
            await provider.fetchHabits();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats row
              Row(
                children: [
                  _StatCard(
                    icon: Icons.track_changes,
                    label: 'Active',
                    value: '${dash.activeHabits}',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.check_circle,
                    label: 'Today',
                    value: '${dash.totalCompletionsToday}',
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.local_fire_department,
                    label: 'Streak',
                    value: '${dash.overallStreak}',
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Top category badge
              if (dash.topCategory != 'none')
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: ListTile(
                    leading: Text(
                      Habit.categoryIcons[dash.topCategory] ?? '⭐',
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: const Text('Top Category'),
                    subtitle: Text(
                      dash.topCategory[0].toUpperCase() + dash.topCategory.substring(1),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // AI Insights
              Text('AI Insights',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              if (dash.insights.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Complete some habits to unlock AI-powered insights!'),
                  ),
                )
              else
                ...dash.insights.map((insight) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  Habit.categoryIcons[insight.habitTitle] ?? '📊',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(insight.habitTitle,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                                _MotivationBadge(level: insight.motivationLevel),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text('${insight.streak} day streak'),
                                const SizedBox(width: 16),
                                const Icon(Icons.pie_chart, size: 16, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text('${(insight.completionRate * 100).toStringAsFixed(0)}% rate'),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(insight.suggestion,
                                      style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MotivationBadge extends StatelessWidget {
  final String level;
  const _MotivationBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'high': Colors.green,
      'medium': Colors.orange,
      'low': Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (colors[level] ?? Colors.grey).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level.toUpperCase(),
        style: TextStyle(
          color: colors[level] ?? Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
