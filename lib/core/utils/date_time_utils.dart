import 'package:intl/intl.dart';

abstract final class DateTimeUtils {
  static final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');

  static String formatDisplayDate(DateTime dateTime) {
    return _displayDateFormat.format(dateTime);
  }

  static int daysBetween(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays;
  }
}
