import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';

class TaskFormDialog extends StatefulWidget {
  final Task? taskToEdit;

  const TaskFormDialog({super.key, this.taskToEdit});

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late TaskPriority _priority;
  late TaskCategory _category;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _title = widget.taskToEdit?.title ?? '';
    _description = widget.taskToEdit?.description ?? '';
    _priority = widget.taskToEdit?.priority ?? TaskPriority.medium;
    _category = widget.taskToEdit?.category ?? TaskCategory.other;
    _dueDate = widget.taskToEdit?.dueDate;
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final provider = Provider.of<TaskProvider>(context, listen: false);
      if (widget.taskToEdit == null) {
        provider.addTask(_title, _description, _priority, _dueDate, _category);
        _showSnackbar('Task created successfully!');
      } else {
        provider.updateTask(widget.taskToEdit!.id, _title, _description, _priority, _dueDate, _category);
        _showSnackbar('Task updated successfully!');
      }
      
      Navigator.of(context).pop();
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: AppTheme.premiumDarkTheme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryAccent,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceDark,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark.withOpacity(0.8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isEditing ? 'Edit Task' : 'New Task',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'What do you need to get done?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        initialValue: _title,
                        decoration: const InputDecoration(labelText: 'Task Title', prefixIcon: Icon(Icons.title)),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a title' : null,
                        onSaved: (value) => _title = value!.trim(),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: _description,
                        decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
                        maxLines: 3,
                        onSaved: (value) => _description = value?.trim() ?? '',
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          DropdownButtonFormField<TaskCategory>(
                            value: _category,
                            decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.folder)),
                            dropdownColor: AppTheme.surfaceDark,
                            items: TaskCategory.values.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() { if (value != null) _category = value; }),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<TaskPriority>(
                            value: _priority,
                            decoration: const InputDecoration(labelText: 'Priority', prefixIcon: Icon(Icons.flag)),
                            dropdownColor: AppTheme.surfaceDark,
                            items: TaskPriority.values.map((priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Text(priority.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() { if (value != null) _priority = value; }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundDark.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: AppTheme.textSecondary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _dueDate == null ? 'Select Due Date (Optional)' : 'Due: ${DateFormatter.formatDueDate(_dueDate)}',
                                  style: TextStyle(
                                    color: _dueDate == null ? AppTheme.textSecondary : Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (_dueDate != null)
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 20, color: AppTheme.textSecondary),
                                  onPressed: () => setState(() => _dueDate = null),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [AppTheme.primaryAccent, AppTheme.secondaryAccent]),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: AppTheme.primaryAccent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                              ),
                              child: ElevatedButton(
                                onPressed: _saveTask,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Text(isEditing ? 'Save Changes' : 'Add Task'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
