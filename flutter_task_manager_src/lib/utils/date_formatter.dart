import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDueDate(DateTime? date) {
    if (date == null) return 'No due date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == tomorrow) {
      return 'Tomorrow';
    } else if (targetDate == yesterday) {
      return 'Yesterday';
    } else if (targetDate.year == today.year) {
      return DateFormat('MMM d').format(targetDate);
    } else {
      return DateFormat('MMM d, yyyy').format(targetDate);
    }
  }

  static bool isOverdue(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    return targetDate.isBefore(today);
  }
}
