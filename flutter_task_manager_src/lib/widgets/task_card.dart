import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import 'task_form_dialog.dart';

class TaskCard extends StatefulWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  
  late AnimationController _entranceController;
  late Animation<double> _entranceOpacity;
  late Animation<Offset> _entranceSlide;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
    
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _entranceOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOut));
    _entranceSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));
    
    _entranceController.forward();
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _showEditForm(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => TaskFormDialog(taskToEdit: widget.task),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack, reverseCurve: Curves.easeIn),
            child: child,
          ),
        );
      },
    );
  }

  void _deleteTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        title: Text('Delete Task', style: Theme.of(context).textTheme.titleLarge),
        content: Text('Are you sure you want to delete this task?', style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).deleteTask(widget.task.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Task deleted!'),
                  backgroundColor: AppTheme.priorityHigh,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.priorityHigh, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor() {
    switch (widget.task.priority) {
      case TaskPriority.high: return AppTheme.priorityHigh;
      case TaskPriority.medium: return AppTheme.priorityMedium;
      case TaskPriority.low: return AppTheme.priorityLow;
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.task.category) {
      case TaskCategory.work: return Icons.work;
      case TaskCategory.personal: return Icons.person;
      case TaskCategory.health: return Icons.favorite;
      case TaskCategory.finance: return Icons.attach_money;
      case TaskCategory.other: return Icons.folder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.status == TaskStatus.completed;
    final isOverdue = !isCompleted && DateFormatter.isOverdue(widget.task.dueDate);

    return FadeTransition(
      opacity: _entranceOpacity,
      child: SlideTransition(
        position: _entranceSlide,
        child: MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            _hoverController.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _hoverController.reverse();
          },
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (_isHovered)
                    BoxShadow(color: AppTheme.primaryAccent.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCompleted ? AppTheme.surfaceDark.withOpacity(0.3) : AppTheme.surfaceDark.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(_isHovered ? 0.2 : 0.05)),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            value: isCompleted,
                            onChanged: (_) {
                              Provider.of<TaskProvider>(context, listen: false).toggleTaskStatus(widget.task.id);
                            },
                            activeColor: AppTheme.primaryAccent,
                            checkColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            side: BorderSide(color: AppTheme.textSecondary.withOpacity(0.5)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.task.title,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                                            color: isCompleted ? AppTheme.textSecondary : Colors.white,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor().withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: _getPriorityColor().withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8, height: 8,
                                          decoration: BoxDecoration(shape: BoxShape.circle, color: _getPriorityColor(), boxShadow: [BoxShadow(color: _getPriorityColor(), blurRadius: 4)]),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          widget.task.priority.name.toUpperCase(),
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getPriorityColor(), letterSpacing: 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.task.description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                                      color: AppTheme.textSecondary,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_getCategoryIcon(), size: 14, color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.task.category.name.toUpperCase(),
                                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  if (widget.task.dueDate != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calendar_today, size: 14, color: isOverdue ? AppTheme.priorityHigh : AppTheme.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormatter.formatDueDate(widget.task.dueDate),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isOverdue ? AppTheme.priorityHigh : AppTheme.textSecondary,
                                            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: (_isHovered || isCompleted) ? 1.0 : 0.0,
                          child: Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 20),
                                onPressed: () => _showEditForm(context),
                                color: AppTheme.textSecondary,
                                hoverColor: Colors.white.withOpacity(0.1),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                onPressed: () => _deleteTask(context),
                                color: AppTheme.priorityHigh.withOpacity(0.8),
                                hoverColor: AppTheme.priorityHigh.withOpacity(0.1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
