// lib/src/models/jalali_date_result.dart

import 'jalali.dart';

/// خروجی انتخاب تاریخ در پکیج.
///
/// هم نمایش شمسی (برای UI و اعتبارسنجی) و هم معادل میلادی
/// (برای ارسال به بک‌اند و ذخیره در دیتابیس) را یکجا می‌دهد.
class JalaliDateResult {
  const JalaliDateResult({
    required this.jalali,
    required this.gregorian,
  });

  /// ساخت از یک [Jalali] با محاسبهٔ خودکار میلادی.
  factory JalaliDateResult.fromJalali(Jalali jalali) {
    return JalaliDateResult(
      jalali: jalali,
      gregorian: jalali.toDateTime(),
    );
  }

  final Jalali jalali;
  final DateTime gregorian;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JalaliDateResult &&
          other.jalali == jalali &&
          other.gregorian == gregorian;

  @override
  int get hashCode => Object.hash(jalali, gregorian);

  @override
  String toString() =>
      'JalaliDateResult(jalali: $jalali, gregorian: $gregorian)';
}