import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceDark.withOpacity(0.5),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: const Icon(Icons.done_all_rounded, size: 80, color: AppTheme.secondaryAccent),
          ),
          const SizedBox(height: 32),
          Text(
            'You\'re all caught up!',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 12),
          Text(
            'Enjoy your free time or add a new task to get started.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
