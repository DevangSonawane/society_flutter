import 'package:intl/intl.dart';

class AppFormatters {
  // Currency Formatter
  static String currency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
  
  // Date Formatter
  static String date(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
  
  static String dateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  // Time Formatter
  static String time(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }
  
  // DateTime Formatter
  static String dateTime(DateTime date) {
    return DateFormat('MMM d, yyyy, h:mm a').format(date);
  }
  
  // Relative Time Formatter
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}

