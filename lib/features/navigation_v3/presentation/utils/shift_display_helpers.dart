// 📁 lib/features/navigation_v3/presentation/utils/shift_display_helpers.dart

/// Pure utility functions for shift display formatting
///
/// ✅ No dependencies - can be used anywhere
/// ✅ Extracted from AvailableShiftsScreen for reusability
/// ✅ Handles date/time formatting and error messages
class ShiftDisplayHelpers {
  /// Format shift date with relative terms (Today, Tomorrow, etc.)
  static String formatShiftDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final shiftDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (shiftDate == today) {
      return 'Today';
    } else if (shiftDate == tomorrow) {
      return 'Tomorrow';
    } else {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];

      final dayName = days[dateTime.weekday - 1];
      final monthName = months[dateTime.month - 1];

      return '$dayName, $monthName ${dateTime.day}';
    }
  }

  /// Format shift time range (e.g., "7:00 AM - 7:00 PM")
  static String formatShiftTime(DateTime startTime, DateTime endTime) {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  /// Format single time with AM/PM
  static String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }

  /// Format shift duration (e.g., "8h", "12h 30m")
  static String formatShiftDuration(DateTime startTime, DateTime endTime) {
    final duration = endTime.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }

  /// Format posted time as relative time (e.g., "2 hours ago")
  static String formatPostedTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      final days = difference.inDays;
      return '$days day${days != 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      return '$hours hour${hours != 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes != 1 ? 's' : ''} ago';
    } else {
      return 'Just posted';
    }
  }

  /// Get user-friendly error message from exception
  static String getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission')) {
      return 'Permission denied. Please contact admin.';
    } else if (errorString.contains('network')) {
      return 'Network error. Check your connection.';
    } else if (errorString.contains('agency')) {
      return 'Agency context missing. Please contact admin.';
    } else {
      return 'Please try again.';
    }
  }
}
