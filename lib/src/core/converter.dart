// lib/src/core/converter.dart
//
// Jalali (Persian) ↔ Gregorian date converter.
//
// این یک پورت وفادار از الگوریتم jalaali-js (Behrang Noruzi Niya) به Dart است.
// همان الگوریتمی که در اکوسیستم JS، Python و کتابخانه‌های Dart مطرح
// (مثل shamsi_date) استفاده می‌شود.
//
// بازهٔ معتبر سال شمسی: -61 تا 3177 (شامل).
// خارج از این بازه، RangeError پرتاب می‌شود.
//
// هیچ وابستگی خارجی ندارد. صرفاً از dart:core استفاده می‌کند.

/// پایین‌ترین سال شمسی پشتیبانی‌شده.
const int minSupportedJalaliYear = -61;

/// بالاترین سال شمسی پشتیبانی‌شده.
const int maxSupportedJalaliYear = 3177;

/// یک تاریخ میلادی به‌صورت record.
typedef GregorianDate = ({int year, int month, int day});

/// یک تاریخ شمسی به‌صورت record.
typedef JalaliDate = ({int year, int month, int day});

// ---------------------------------------------------------------------------
// API عمومی
// ---------------------------------------------------------------------------

/// تبدیل تاریخ شمسی به میلادی.
///
/// مثال:
/// ```dart
/// final g = jalaliToGregorian(1403, 1, 1);
/// // g == (year: 2024, month: 3, day: 20)
/// ```
GregorianDate jalaliToGregorian(int jy, int jm, int jd) {
  _assertValidJalali(jy, jm, jd);
  final g = _d2g(_j2d(jy, jm, jd));
  return (year: g.gy, month: g.gm, day: g.gd);
}

/// تبدیل تاریخ میلادی به شمسی.
///
/// مثال:
/// ```dart
/// final j = gregorianToJalali(2024, 3, 20);
/// // j == (year: 1403, month: 1, day: 1)
/// ```
JalaliDate gregorianToJalali(int gy, int gm, int gd) {
  if (gm < 1 || gm > 12) {
    throw RangeError.range(gm, 1, 12, 'gm', 'Gregorian month out of range');
  }
  if (gd < 1 || gd > 31) {
    throw RangeError.range(gd, 1, 31, 'gd', 'Gregorian day out of range');
  }
  final j = _d2j(_g2d(gy, gm, gd));
  return (year: j.year, month: j.month, day: j.day);
}

/// آیا سال شمسی داده‌شده کبیسه است؟
bool isLeapJalaliYear(int jy) {
  _checkJalaliYearRange(jy);
  return _jalCal(jy).leap == 0;
}

/// تعداد روزهای ماه شمسی داده‌شده.
///
/// ماه‌های ۱ تا ۶: ۳۱ روز، ماه‌های ۷ تا ۱۱: ۳۰ روز،
/// ماه ۱۲: ۲۹ یا ۳۰ روز (در سال کبیسه ۳۰).
int jalaliMonthLength(int jy, int jm) {
  _checkJalaliYearRange(jy);
  if (jm < 1 || jm > 12) {
    throw RangeError.range(jm, 1, 12, 'jm', 'Jalali month out of range');
  }
  if (jm <= 6) return 31;
  if (jm <= 11) return 30;
  return isLeapJalaliYear(jy) ? 30 : 29;
}

// ---------------------------------------------------------------------------
// پیاده‌سازی داخلی — پورت jalaali-js
// ---------------------------------------------------------------------------

const List<int> _breaks = [
  -61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210,
  1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178,
];

/// تقسیم صحیح با truncation (مطابق `~~(a / b)` در جاوااسکریپت).
int _div(int a, int b) => (a / b).truncate();

/// باقیمانده با علامت مقسوم (مطابق `a - ~~(a / b) * b` در جاوااسکریپت).
int _mod(int a, int b) => a - _div(a, b) * b;

typedef _CalResult = ({int leap, int gy, int march});

_CalResult _jalCal(int jy) {
  _checkJalaliYearRange(jy);

  final gy = jy + 621;
  var leapJ = -14;
  var jp = _breaks.first;
  var jump = 0;

  for (var i = 1; i < _breaks.length; i++) {
    final jm = _breaks[i];
    jump = jm - jp;
    if (jy < jm) break;
    leapJ += _div(jump, 33) * 8 + _div(_mod(jump, 33), 4);
    jp = jm;
  }

  var n = jy - jp;
  leapJ += _div(n, 33) * 8 + _div(_mod(n, 33) + 3, 4);
  if (_mod(jump, 33) == 4 && jump - n == 4) leapJ += 1;

  final leapG = _div(gy, 4) - _div((_div(gy, 100) + 1) * 3, 4) - 150;
  final march = 20 + leapJ - leapG;

  if (jump - n < 6) n = n - jump + _div(jump + 4, 33) * 33;
  var leap = _mod(_mod(n + 1, 33) - 1, 4);
  if (leap == -1) leap = 4;

  return (leap: leap, gy: gy, march: march);
}

typedef _GDate = ({int gy, int gm, int gd});

int _g2d(int gy, int gm, int gd) {
  var d = _div((gy + _div(gm - 8, 6) + 100100) * 1461, 4) +
      _div(153 * _mod(gm + 9, 12) + 2, 5) +
      gd -
      34840408;
  d = d - _div(_div(gy + 100100 + _div(gm - 8, 6), 100) * 3, 4) + 752;
  return d;
}

_GDate _d2g(int jdn) {
  var j = 4 * jdn + 139361631;
  j = j + _div(_div(4 * jdn + 183187720, 146097) * 3, 4) * 4 - 3908;
  final i = _div(_mod(j, 1461), 4) * 5 + 308;
  final gd = _div(_mod(i, 153), 5) + 1;
  final gm = _mod(_div(i, 153), 12) + 1;
  final gy = _div(j, 1461) - 100100 + _div(8 - gm, 6);
  return (gy: gy, gm: gm, gd: gd);
}

int _j2d(int jy, int jm, int jd) {
  final r = _jalCal(jy);
  return _g2d(r.gy, 3, r.march) +
      (jm - 1) * 31 -
      _div(jm, 7) * (jm - 7) +
      jd -
      1;
}

JalaliDate _d2j(int jdn) {
  final gy = _d2g(jdn).gy;
  var jy = gy - 621;
  final r = _jalCal(jy);
  final jdn1f = _g2d(gy, 3, r.march);
  var k = jdn - jdn1f;

  if (k >= 0) {
    if (k <= 185) {
      return (year: jy, month: 1 + _div(k, 31), day: _mod(k, 31) + 1);
    }
    k -= 186;
  } else {
    jy -= 1;
    k += 179;
    if (r.leap == 1) k += 1;
  }
  return (year: jy, month: 7 + _div(k, 30), day: _mod(k, 30) + 1);
}

void _checkJalaliYearRange(int jy) {
  if (jy < minSupportedJalaliYear || jy > maxSupportedJalaliYear) {
    throw RangeError.range(
      jy,
      minSupportedJalaliYear,
      maxSupportedJalaliYear,
      'jy',
      'Jalali year out of supported range',
    );
  }
}

void _assertValidJalali(int jy, int jm, int jd) {
  _checkJalaliYearRange(jy);
  if (jm < 1 || jm > 12) {
    throw RangeError.range(jm, 1, 12, 'jm', 'Jalali month out of range');
  }
  final len = jalaliMonthLength(jy, jm);
  if (jd < 1 || jd > len) {
    throw RangeError.range(
      jd,
      1,
      len,
      'jd',
      'Day out of range for $jy/$jm (max $len)',
    );
  }
}