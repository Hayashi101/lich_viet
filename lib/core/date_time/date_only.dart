DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool isSameDate(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

DateTime startOfWeek(DateTime value) {
  final date = dateOnly(value);
  return date.subtract(Duration(days: date.weekday - DateTime.monday));
}

DateTime endOfWeek(DateTime value) =>
    startOfWeek(value).add(const Duration(days: 6));
