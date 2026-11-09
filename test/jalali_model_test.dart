// test/jalali_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:jalali_birth_date_picker/src/models/jalali.dart';

void main() {
  group('ساخت و اعتبارسنجی', () {
    test('ساخت معتبر', () {
      final j = Jalali(1403, 1, 1);
      expect(j.year, 1403);
      expect(j.month, 1);
      expect(j.day, 1);
    });

    test('ماه نامعتبر → RangeError', () {
      expect(() => Jalali(1403, 0, 1), throwsRangeError);
      expect(() => Jalali(1403, 13, 1), throwsRangeError);
    });

    test('روز نامعتبر → RangeError', () {
      expect(() => Jalali(1403, 1, 0), throwsRangeError);
      expect(() => Jalali(1403, 1, 32), throwsRangeError);
    });

    test('اسفند ۳۰ در سال غیرکبیسه → RangeError', () {
      expect(() => Jalali(1402, 12, 30), throwsRangeError);
    });

    test('اسفند ۳۰ در سال کبیسه مجاز است', () {
      expect(() => Jalali(1403, 12, 30), returnsNormally);
    });
  });

  group('برابری و هش', () {
    test('دو تاریخ یکسان برابرند', () {
      final a = Jalali(1403, 1, 1);
      final b = Jalali(1403, 1, 1);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('تاریخ‌های متفاوت برابر نیستند', () {
      expect(Jalali(1403, 1, 1), isNot(Jalali(1403, 1, 2)));
      expect(Jalali(1403, 1, 1), isNot(Jalali(1403, 2, 1)));
      expect(Jalali(1403, 1, 1), isNot(Jalali(1404, 1, 1)));
    });
  });

  group('مقایسه', () {
    test('isBefore / isAfter', () {
      final a = Jalali(1402, 12, 29);
      final b = Jalali(1403, 1, 1);
      expect(a.isBefore(b), isTrue);
      expect(b.isAfter(a), isTrue);
      expect(a.isAfter(b), isFalse);
      expect(b.isBefore(a), isFalse);
    });

    test('عملگرها', () {
      final a = Jalali(1403, 1, 1);
      final b = Jalali(1403, 1, 2);
      expect(a < b, isTrue);
      expect(a <= b, isTrue);
      expect(b > a, isTrue);
      expect(b >= a, isTrue);
      expect(a >= b, isFalse);
      expect(a == a, isTrue);
      expect(a <= a, isTrue);
    });

    test('compareTo', () {
      expect(Jalali(1403, 1, 1).compareTo(Jalali(1403, 1, 2)), -1);
      expect(Jalali(1403, 1, 2).compareTo(Jalali(1403, 1, 1)), 1);
      expect(Jalali(1403, 1, 1).compareTo(Jalali(1403, 1, 1)), 0);
    });
  });

  group('خواص مشتق', () {
    test('isLeapYear', () {
      expect(Jalali(1403, 1, 1).isLeapYear, isTrue);
      expect(Jalali(1402, 1, 1).isLeapYear, isFalse);
    });

    test('monthLength', () {
      expect(Jalali(1403, 1, 1).monthLength, 31);
      expect(Jalali(1403, 7, 1).monthLength, 30);
      expect(Jalali(1403, 12, 1).monthLength, 30); // کبیسه
      expect(Jalali(1402, 12, 1).monthLength, 29); // غیرکبیسه
    });

    test('firstDayOfMonth و lastDayOfMonth', () {
      final d = Jalali(1403, 7, 15);
      expect(d.firstDayOfMonth, Jalali(1403, 7, 1));
      expect(d.lastDayOfMonth, Jalali(1403, 7, 30));
    });

    test('firstDayOfYear و lastDayOfYear در سال کبیسه', () {
      final d = Jalali(1403, 6, 15);
      expect(d.firstDayOfYear, Jalali(1403, 1, 1));
      expect(d.lastDayOfYear, Jalali(1403, 12, 30));
    });

    test('firstDayOfYear و lastDayOfYear در سال غیرکبیسه', () {
      final d = Jalali(1402, 6, 15);
      expect(d.firstDayOfYear, Jalali(1402, 1, 1));
      expect(d.lastDayOfYear, Jalali(1402, 12, 29));
    });
  });

  group('persianWeekday', () {
    test('2024-03-20 = 1403/01/01 = چهارشنبه (۵)', () {
      expect(Jalali(1403, 1, 1).persianWeekday, 5);
    });

    test('2024-03-19 = 1402/12/29 = سه‌شنبه (۴)', () {
      expect(Jalali(1402, 12, 29).persianWeekday, 4);
    });

    test('2024-03-22 = 1403/01/03 = جمعه (۷)', () {
      expect(Jalali(1403, 1, 3).persianWeekday, 7);
    });

    test('2024-03-23 = 1403/01/04 = شنبه (۱)', () {
      expect(Jalali(1403, 1, 4).persianWeekday, 1);
    });

    test('مقدار همیشه بین ۱ و ۷ است (روی ۴۰۰ روز متوالی)', () {
      var j = Jalali(1403, 1, 1);
      for (var i = 0; i < 400; i++) {
        expect(
          j.persianWeekday,
          inInclusiveRange(1, 7),
          reason: 'day $j (index $i)',
        );

        // رفتن به روز بعد بدون شکستن اعتبارسنجی
        if (j.day < j.monthLength) {
          j = j.copyWith(day: j.day + 1);
        } else if (j.month < 12) {
          j = Jalali(j.year, j.month + 1, 1);
        } else {
          j = Jalali(j.year + 1, 1, 1);
        }
      }
    });
  });

  group('addYears', () {
    test('حالت ساده', () {
      final j = Jalali(1400, 5, 12);
      expect(j.addYears(3), Jalali(1403, 5, 12));
      expect(j.addYears(-3), Jalali(1397, 5, 12));
    });

    test('clamp اسفند ۳۰ در سال کبیسه به ۲۹ در سال غیرکبیسه', () {
      final leapEsfand = Jalali(1403, 12, 30);
      expect(leapEsfand.addYears(1), Jalali(1404, 12, 29));
    });

    test('روز ۲۹ اسفند بدون تغییر می‌ماند', () {
      final d = Jalali(1403, 12, 29);
      expect(d.addYears(1), Jalali(1404, 12, 29));
    });

    test('از سال غیرکبیسه به کبیسه، روز حفظ می‌شود', () {
      final d = Jalali(1402, 12, 29);
      expect(d.addYears(1), Jalali(1403, 12, 29));
    });

    test('خروج از بازهٔ پشتیبانی → RangeError', () {
      expect(() => Jalali(1403, 1, 1).addYears(2000), throwsRangeError);
    });
  });

  group('addDays', () {
    test('صفر → همان تاریخ', () {
      final d = Jalali(1403, 5, 12);
      expect(d.addDays(0), d);
    });

    test('درون ماه', () {
      expect(Jalali(1403, 1, 5).addDays(3), Jalali(1403, 1, 8));
      expect(Jalali(1403, 1, 10).addDays(-4), Jalali(1403, 1, 6));
    });

    test('عبور از مرز ماه (جلو)', () {
      expect(Jalali(1403, 1, 31).addDays(1), Jalali(1403, 2, 1));
      expect(Jalali(1403, 6, 31).addDays(1), Jalali(1403, 7, 1));
      expect(Jalali(1403, 11, 30).addDays(1), Jalali(1403, 12, 1));
    });

    test('عبور از مرز سال (جلو) در سال غیرکبیسه', () {
      expect(Jalali(1402, 12, 29).addDays(1), Jalali(1403, 1, 1));
    });

    test('عبور از مرز سال (جلو) در سال کبیسه', () {
      expect(Jalali(1403, 12, 30).addDays(1), Jalali(1404, 1, 1));
    });

    test('عبور از مرز ماه (عقب)', () {
      expect(Jalali(1403, 2, 1).addDays(-1), Jalali(1403, 1, 31));
      expect(Jalali(1403, 7, 1).addDays(-1), Jalali(1403, 6, 31));
      expect(Jalali(1403, 12, 1).addDays(-1), Jalali(1403, 11, 30));
    });

    test('عبور از مرز سال (عقب) به سال غیرکبیسه', () {
      expect(Jalali(1403, 1, 1).addDays(-1), Jalali(1402, 12, 29));
    });

    test('عبور از مرز سال (عقب) به سال کبیسه', () {
      expect(Jalali(1404, 1, 1).addDays(-1), Jalali(1403, 12, 30));
    });

    test('پرش بزرگ (یک سال شمسی ≈ ۳۶۵ یا ۳۶۶ روز)', () {
      final start = Jalali(1403, 1, 1);
      expect(start.addDays(366), Jalali(1404, 1, 1)); // ۱۴۰۳ کبیسه
      final start2 = Jalali(1402, 1, 1);
      expect(start2.addDays(365), Jalali(1403, 1, 1)); // ۱۴۰۲ غیرکبیسه
    });

    test('رفت و برگشت: addDays(n) و بعد addDays(-n) همان تاریخ اولیه', () {
      for (final start in [
        Jalali(1403, 1, 1),
        Jalali(1403, 6, 31),
        Jalali(1403, 12, 30),
        Jalali(1402, 12, 29),
        Jalali(1400, 5, 12),
      ]) {
        for (final n in [1, 5, 30, 100, 365]) {
          final forward = start.addDays(n);
          final back = forward.addDays(-n);
          expect(back, start, reason: 'start=$start, n=$n');
        }
      }
    });
  });

  group('copyWith', () {
    test('تغییر یک بخش، بقیه را نگه می‌دارد', () {
      final d = Jalali(1403, 5, 12);
      expect(d.copyWith(day: 20), Jalali(1403, 5, 20));
      expect(d.copyWith(month: 1), Jalali(1403, 1, 12));
      expect(d.copyWith(year: 1400), Jalali(1400, 5, 12));
    });

    test('بدون آرگومان، معادل خودش برمی‌گرداند', () {
      final d = Jalali(1403, 5, 12);
      expect(d.copyWith(), d);
    });
  });

  group('تبدیل به/از DateTime', () {
    test('toDateTime', () {
      final dt = Jalali(1403, 1, 1).toDateTime();
      expect((dt.year, dt.month, dt.day), (2024, 3, 20));
    });

    test('fromDateTime', () {
      final j = Jalali.fromDateTime(DateTime(2024, 3, 20));
      expect(j, Jalali(1403, 1, 1));
    });

    test('round-trip', () {
      for (final j in [
        Jalali(1357, 1, 1),
        Jalali(1399, 12, 30),
        Jalali(1403, 6, 15),
        Jalali(1450, 9, 22),
      ]) {
        final back = Jalali.fromDateTime(j.toDateTime());
        expect(back, j);
      }
    });

    test('ساعت و دقیقه نادیده گرفته می‌شوند', () {
      final dt = DateTime(2024, 3, 20, 14, 35, 22);
      final j = Jalali.fromDateTime(dt);
      expect(j, Jalali(1403, 1, 1));
    });
  });

  group('Jalali.now', () {
    test('امروز معتبر است', () {
      final now = Jalali.now();
      expect(now.year, greaterThan(1300));
      expect(now.month, inInclusiveRange(1, 12));
      expect(now.day, inInclusiveRange(1, now.monthLength));
    });
  });

  group('toString', () {
    test('خروجی استاندارد', () {
      expect(Jalali(1403, 1, 5).toString(), '1403/1/5');
    });
  });
}
