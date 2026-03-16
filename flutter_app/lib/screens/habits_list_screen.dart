import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class HabitsListScreen extends StatelessWidget {
  const HabitsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.habits.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.habits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_task, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('No habits yet', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Tap + to create your first habit!', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.fetchHabits,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.habits.length,
            itemBuilder: (context, index) {
              final habit = provider.habits[index];
              return _HabitCard(habit: habit);
            },
          ),
        );
      },
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final emoji = Habit.categoryIcons[habit.category] ?? '⭐';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showCompleteDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    if (habit.description.isNotEmpty)
                      Text(habit.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _Tag(label: habit.category),
                        const SizedBox(width: 8),
                        _Tag(label: habit.frequency),
                        const Spacer(),
                        Icon(Icons.check_circle, size: 16, color: Colors.green[400]),
                        const SizedBox(width: 4),
                        Text('${habit.completionCount}', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'delete') _confirmDelete(context);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompleteDialog(BuildContext context) {
    final noteCtrl = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Complete "${habit.title}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 16),
              Text('Rating: ${rating.toStringAsFixed(0)}/10'),
              Slider(
                value: rating,
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (v) => setDialogState(() => rating = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                context.read<HabitProvider>().completeHabit(
                      habit.id,
                      note: noteCtrl.text,
                      rating: rating,
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Habit completed! 🎉'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Complete'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: Text('Are you sure you want to delete "${habit.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<HabitProvider>().deleteHabit(habit.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}
