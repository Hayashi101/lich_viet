final class LunarDate {
  const LunarDate({
    required this.day,
    required this.month,
    required this.year,
    this.isLeapMonth = false,
  });

  final int day;
  final int month;
  final int year;
  final bool isLeapMonth;

  String get compactLabel => '$day/$month';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LunarDate &&
          day == other.day &&
          month == other.month &&
          year == other.year &&
          isLeapMonth == other.isLeapMonth;

  @override
  int get hashCode => Object.hash(day, month, year, isLeapMonth);

  @override
  String toString() =>
      'LunarDate($day/$month/$year${isLeapMonth ? ', leap' : ''})';
}
