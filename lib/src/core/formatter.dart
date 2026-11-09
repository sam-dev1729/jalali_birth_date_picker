// lib/src/core/formatter.dart

import '../models/jalali.dart';
import 'constants.dart';

/// توکن‌های پشتیبانی‌شده در الگو:
///
/// - `yyyy` — سال چهاررقمی (مثلاً ۱۴۰۳)
/// - `yy`   — دو رقم آخر سال (مثلاً ۰۳)
/// - `MMMM` — نام کامل ماه (مثلاً فروردین)
/// - `MM`   — شماره ماه دورقمی (مثلاً ۰۱)
/// - `M`    — شماره ماه تک‌رقمی (مثلاً ۱)
/// - `dd`   — روز دورقمی (مثلاً ۰۵)
/// - `d`    — روز تک‌رقمی (مثلاً ۵)
///
/// سایر کاراکترها (مثل `/`، `-`، فاصله) عیناً حفظ می‌شوند.
///
/// مثال:
/// ```dart
/// formatJalali(Jalali(1403, 1, 5), 'yyyy/MM/dd');           // '1403/01/05'
/// formatJalali(Jalali(1403, 1, 5), 'd MMMM yyyy');          // '5 فروردین 1403'
/// formatJalali(Jalali(1403, 1, 5), 'yyyy/MM/dd',
///     persianDigits: true);                                 // '۱۴۰۳/۰۱/۰۵'
/// ```
String formatJalali(
  Jalali date,
  String pattern, {
  bool persianDigits = false,
}) {
  String two(int v) => v.toString().padLeft(2, '0');

  final tokens = <String, String>{
    'yyyy': date.year.toString(),
    'yy': (date.year % 100).toString().padLeft(2, '0'),
    'MMMM': jalaliMonthNames[date.month - 1],
    'MM': two(date.month),
    'M': date.month.toString(),
    'dd': two(date.day),
    'd': date.day.toString(),
  };

  // ترتیب در alternation مهم است: طولانی‌ترها اول تا مثلاً yyyy قبل از yy
  // و MM قبل از M گرفته شود.
  final patternRegex = RegExp('yyyy|yy|MMMM|MM|dd|M|d');

  var out = pattern.replaceAllMapped(
    patternRegex,
    (m) => tokens[m[0]] ?? m[0]!,
  );

  if (persianDigits) {
    out = toPersianDigits(out);
  }
  return out;
}

/// تبدیل ارقام لاتین به فارسی. کاراکترهای غیررقمی دست‌نخورده می‌مانند.
String toPersianDigits(String input) {
  final buffer = StringBuffer();
  for (final ch in input.split('')) {
    buffer.write(latinToPersianDigits[ch] ?? ch);
  }
  return buffer.toString();
}

/// تبدیل ارقام فارسی/عربی به لاتین. برای نرمال‌سازی ورودی کاربر
/// (در نسخه‌های بعد که حالت ورود دستی اضافه شود) مفید است.
String toLatinDigits(String input) {
  final buffer = StringBuffer();
  for (final ch in input.split('')) {
    buffer.write(persianToLatinDigits[ch] ?? ch);
  }
  return buffer.toString();
}
