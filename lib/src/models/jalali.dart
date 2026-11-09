// lib/src/models/jalali.dart

import '../core/converter.dart';

/// یک تاریخ شمسی immutable.
///
/// - مقایسه‌پذیر (`Comparable<Jalali>`) با `==`، `<`، `<=`، `>`، `>=`
/// - قابل تبدیل به میلادی با [toDateTime]
/// - ساخت از میلادی با [Jalali.fromDateTime]
///
/// در صورت ورودی نامعتبر (ماه ۱۳، روز ۳۲، اسفند ۳۰ در سال غیرکبیسه و ...)
/// استثنای [RangeError] پرتاب می‌شود.
///
/// مثال:
/// ```dart
/// final today = Jalali.now();
/// final birth = Jalali(1370, 5, 12);
/// if (birth.isBefore(today)) { /* ... */ }
/// ```
class Jalali implements Comparable<Jalali> {
  /// سازندهٔ داخلی بدون اعتبارسنجی — فقط برای مسیرهای امن (تبدیل‌های
  /// داخلی که خروجی‌شان همیشه معتبر است) استفاده می‌شود.
  const Jalali._(this.year, this.month, this.day);

  /// ساخت تاریخ شمسی با اعتبارسنجی کامل.
  factory Jalali(int year, int month, int day) {
    _validate(year, month, day);
    return Jalali._(year, month, day);
  }

  /// تاریخ امروز (بر اساس ساعت سیستم، منطقهٔ زمانی محلی).
  factory Jalali.now() => Jalali.fromDateTime(DateTime.now());

  /// ساخت از یک [DateTime] میلادی. فقط بخش سال/ماه/روز استفاده می‌شود؛
  /// ساعت، دقیقه و منطقهٔ زمانی نادیده گرفته می‌شوند.
  factory Jalali.fromDateTime(DateTime dt) {
    final j = gregorianToJalali(dt.year, dt.month, dt.day);
    return Jalali._(j.year, j.month, j.day);
  }

  final int year;
  final int month;
  final int day;

  // -------------------------------------------------------------------------
  // خواص مشتق‌شده
  // -------------------------------------------------------------------------

  bool get isLeapYear => isLeapJalaliYear(year);

  int get monthLength => jalaliMonthLength(year, month);

  /// روز هفتهٔ ایرانی: ۱ = شنبه، …، ۷ = جمعه.
  ///
  /// از UTC استفاده می‌کند تا مستقل از منطقهٔ زمانی و DST باشد.
  int get persianWeekday {
    final g = jalaliToGregorian(year, month, day);
    final wd = DateTime.utc(g.year, g.month, g.day).weekday; // 1=Mon..7=Sun
    return ((wd + 1) % 7) + 1;
  }

  Jalali get firstDayOfMonth => Jalali._(year, month, 1);

  Jalali get lastDayOfMonth => Jalali._(year, month, monthLength);

  Jalali get firstDayOfYear => Jalali._(year, 1, 1);

  Jalali get lastDayOfYear => Jalali._(year, 12, jalaliMonthLength(year, 12));

  // -------------------------------------------------------------------------
  // تبدیل‌ها
  // -------------------------------------------------------------------------

  /// معادل میلادی، در نیمه‌شب محلی. برای ارسال به بک‌اند.
  DateTime toDateTime() {
    final g = jalaliToGregorian(year, month, day);
    return DateTime(g.year, g.month, g.day);
  }

  // -------------------------------------------------------------------------
  // عملیات
  // -------------------------------------------------------------------------

  /// افزودن/کاهش سال با clamp کردن روز در صورت کبیسه نبودن سال مقصد.
  ///
  /// مثال: `1403/12/30` (کبیسه) با `addYears(1)` می‌شود `1404/12/29`
  /// چون ۱۴۰۴ کبیسه نیست و اسفند ۲۹ روز دارد.
  Jalali addYears(int years) {
    final ny = year + years;
    final maxDay = jalaliMonthLength(ny, month);
    return Jalali(ny, month, day > maxDay ? maxDay : day);
  }

  /// افزودن/کاهش روز. مقادیر منفی هم پشتیبانی می‌شوند.
  ///
  /// پیچیدگی O(|days|) است — برای حرکت‌های کوتاه در ویجت تقویم کاملاً
  /// کافی است. برای پرش‌های خیلی بزرگ، به‌جای این متد از
  /// `Jalali.fromDateTime(toDateTime().add(Duration(days: n)))`
  /// استفاده کن (با آگاهی از اثر DST).
  Jalali addDays(int days) {
    if (days == 0) return this;

    var j = this;
    if (days > 0) {
      for (var i = 0; i < days; i++) {
        if (j.day < j.monthLength) {
          j = j.copyWith(day: j.day + 1);
        } else if (j.month < 12) {
          j = Jalali(j.year, j.month + 1, 1);
        } else {
          j = Jalali(j.year + 1, 1, 1);
        }
      }
    } else {
      for (var i = 0; i < -days; i++) {
        if (j.day > 1) {
          j = j.copyWith(day: j.day - 1);
        } else if (j.month > 1) {
          final pm = j.month - 1;
          j = Jalali(j.year, pm, jalaliMonthLength(j.year, pm));
        } else {
          final py = j.year - 1;
          j = Jalali(py, 12, jalaliMonthLength(py, 12));
        }
      }
    }
    return j;
  }

  /// کپی با تغییر بخش‌های دلخواه.
  Jalali copyWith({int? year, int? month, int? day}) {
    return Jalali(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
    );
  }

  // -------------------------------------------------------------------------
  // مقایسه
  // -------------------------------------------------------------------------

  bool isBefore(Jalali other) => compareTo(other) < 0;
  bool isAfter(Jalali other) => compareTo(other) > 0;
  bool isSameDayAs(Jalali other) => this == other;

  @override
  int compareTo(Jalali other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  bool operator <(Jalali other) => compareTo(other) < 0;
  bool operator <=(Jalali other) => compareTo(other) <= 0;
  bool operator >(Jalali other) => compareTo(other) > 0;
  bool operator >=(Jalali other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Jalali &&
          other.year == year &&
          other.month == month &&
          other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$year/$month/$day';

  // -------------------------------------------------------------------------
  // اعتبارسنجی داخلی
  // -------------------------------------------------------------------------

  static void _validate(int year, int month, int day) {
    if (year < minSupportedJalaliYear || year > maxSupportedJalaliYear) {
      throw RangeError.range(
        year,
        minSupportedJalaliYear,
        maxSupportedJalaliYear,
        'year',
      );
    }
    if (month < 1 || month > 12) {
      throw RangeError.range(month, 1, 12, 'month');
    }
    final len = jalaliMonthLength(year, month);
    if (day < 1 || day > len) {
      throw RangeError.range(
        day,
        1,
        len,
        'day',
        'Day out of range for $year/$month (max $len)',
      );
    }
  }
}
