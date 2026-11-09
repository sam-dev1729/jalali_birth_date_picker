// lib/src/core/grid.dart

import '../models/jalali.dart';

const int _cellsPerWeek = 7;
const int _maxWeeksInMonth = 6;

/// ساخت شبکهٔ ماهانه برای یک ماه شمسی.
///
/// قرارداد:
/// - ستون اول همیشه **شنبه** است (عرف تقویم ایران).
/// - طول خروجی همیشه مضرب ۷ است.
/// - خانه‌های `null` نشان‌دهندهٔ جای خالی برای هم‌تراز کردن روز اول ماه
///   با ستون درست هستند.
/// - موقعیت روز اول ماه در خروجی همیشه `persianWeekday - 1` است
///   (شنبه → ۰، جمعه → ۶).
///
/// پارامتر [padTo6Weeks]:
/// - `true` (پیش‌فرض): خروجی همیشه ۴۲ خانه (۶ هفته) است، تا ارتفاع
///   تقویم بین ماه‌ها نپرد. این حالت برای فیلد انتخاب تاریخ در
///   فرم ثبت‌نام توصیه می‌شود.
/// - `false`: خروجی حداقلی است (۳۵ یا ۴۲ خانه). برای طراحی فشرده.
///
/// مثال:
/// ```dart
/// final grid = buildMonthGrid(Jalali(1403, 1, 1));
/// // grid.length == 42
/// // grid[0..3] == null  (چهارشنبه، پس ۴ خانه خالی)
/// // grid[4] == Jalali(1403, 1, 1)
/// ```
List<Jalali?> buildMonthGrid(
  Jalali month, {
  bool padTo6Weeks = true,
}) {
  final first = month.firstDayOfMonth;
  final leading = first.persianWeekday - 1; // شنبه = ۰، جمعه = ۶
  final daysInMonth = month.monthLength;

  final cells = <Jalali?>[
    ...List<Jalali?>.filled(leading, null),
    for (var d = 1; d <= daysInMonth; d++) Jalali(month.year, month.month, d),
  ];

  final targetLength = padTo6Weeks
      ? _cellsPerWeek * _maxWeeksInMonth
      : ((cells.length + _cellsPerWeek - 1) ~/ _cellsPerWeek) * _cellsPerWeek;

  while (cells.length < targetLength) {
    cells.add(null);
  }

  return List<Jalali?>.unmodifiable(cells);
}
