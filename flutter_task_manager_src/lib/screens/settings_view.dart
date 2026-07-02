import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32)),
          const SizedBox(height: 8),
          Text('Manage your data and application preferences.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 48),
          _buildSettingsCard(
            context,
            icon: Icons.delete_sweep_rounded,
            title: 'Clear All Data',
            description: 'Permanently delete all tasks and reset your progress.',
            color: AppTheme.priorityHigh,
            onTap: () => _showClearDataDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required IconData icon, required String title, required String description, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(description, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: Text('Clear All Data?', style: Theme.of(context).textTheme.titleLarge),
        content: Text('This action cannot be undone. All your tasks will be permanently deleted.', style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).clearAllTasks();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All data cleared successfully.'),
                  backgroundColor: AppTheme.primaryAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.priorityHigh, foregroundColor: Colors.white),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}
