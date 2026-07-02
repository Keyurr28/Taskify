import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.backgroundDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: TaskFilter.values.map((filter) {
              final isSelected = provider.currentFilter == filter;
              return GestureDetector(
                onTap: () => provider.setFilter(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.surfaceDark : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : [],
                  ),
                  child: Text(
                    filter.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
