// test/converter_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:jalali_birth_date_picker/src/core/converter.dart';

void main() {
  group('تبدیل شمسی → میلادی برای نوروز سال‌های مرجع', () {
    test('1403/01/01 = 2024/03/20', () {
      final g = jalaliToGregorian(1403, 1, 1);
      expect((g.year, g.month, g.day), (2024, 3, 20));
    });

    test('1402/01/01 = 2023/03/21', () {
      final g = jalaliToGregorian(1402, 1, 1);
      expect((g.year, g.month, g.day), (2023, 3, 21));
    });

    test('1404/01/01 = 2025/03/21', () {
      final g = jalaliToGregorian(1404, 1, 1);
      expect((g.year, g.month, g.day), (2025, 3, 21));
    });

    test('1401/01/01 = 2022/03/21', () {
      final g = jalaliToGregorian(1401, 1, 1);
      expect((g.year, g.month, g.day), (2022, 3, 21));
    });

    test('1400/01/01 = 2021/03/21', () {
      final g = jalaliToGregorian(1400, 1, 1);
      expect((g.year, g.month, g.day), (2021, 3, 21));
    });

    test('1399/01/01 = 2020/03/20', () {
      final g = jalaliToGregorian(1399, 1, 1);
      expect((g.year, g.month, g.day), (2020, 3, 20));
    });

    test('1398/01/01 = 2019/03/21', () {
      final g = jalaliToGregorian(1398, 1, 1);
      expect((g.year, g.month, g.day), (2019, 3, 21));
    });

    test('1357/01/01 = 1978/03/21', () {
      final g = jalaliToGregorian(1357, 1, 1);
      expect((g.year, g.month, g.day), (1978, 3, 21));
    });
  });

  group('تبدیل میلادی → شمسی', () {
    test('2024/03/20 = 1403/01/01', () {
      final j = gregorianToJalali(2024, 3, 20);
      expect((j.year, j.month, j.day), (1403, 1, 1));
    });

    test('2024/03/19 = 1402/12/29 (آخرین روز ۱۴۰۲، غیرکبیسه)', () {
      final j = gregorianToJalali(2024, 3, 19);
      expect((j.year, j.month, j.day), (1402, 12, 29));
    });

    test('2025/03/20 = 1403/12/30 (آخرین روز ۱۴۰۳، کبیسه)', () {
      final j = gregorianToJalali(2025, 3, 20);
      expect((j.year, j.month, j.day), (1403, 12, 30));
    });
  });

  group('تشخیص کبیسه', () {
    test('سال‌های کبیسه', () {
      expect(isLeapJalaliYear(1399), isTrue);
      expect(isLeapJalaliYear(1403), isTrue);
    });

    test('سال‌های غیرکبیسه', () {
      expect(isLeapJalaliYear(1400), isFalse);
      expect(isLeapJalaliYear(1401), isFalse);
      expect(isLeapJalaliYear(1402), isFalse);
      expect(isLeapJalaliYear(1404), isFalse);
    });
  });

  group('طول ماه‌ها', () {
    test('شش ماه اول ۳۱ روز', () {
      for (var m = 1; m <= 6; m++) {
        expect(jalaliMonthLength(1403, m), 31, reason: 'ماه $m');
      }
    });

    test('ماه‌های ۷ تا ۱۱ سی روز', () {
      for (var m = 7; m <= 11; m++) {
        expect(jalaliMonthLength(1403, m), 30, reason: 'ماه $m');
      }
    });

    test('اسفند در سال کبیسه ۳۰ روز', () {
      expect(jalaliMonthLength(1403, 12), 30);
      expect(jalaliMonthLength(1399, 12), 30);
    });

    test('اسفند در سال غیرکبیسه ۲۹ روز', () {
      expect(jalaliMonthLength(1402, 12), 29);
      expect(jalaliMonthLength(1404, 12), 29);
    });
  });

  group('Round-trip شمسی → میلادی → شمسی', () {
    test('بازهٔ ۱۳۰۰ تا ۱۴۵۰ (همهٔ روزهای هر ماه)', () {
      for (var jy = 1300; jy <= 1450; jy++) {
        for (var jm = 1; jm <= 12; jm++) {
          final len = jalaliMonthLength(jy, jm);
          for (var jd = 1; jd <= len; jd++) {
            final g = jalaliToGregorian(jy, jm, jd);
            final back = gregorianToJalali(g.year, g.month, g.day);
            expect(
              (back.year, back.month, back.day),
              (jy, jm, jd),
              reason: 'round-trip failed for $jy/$jm/$jd '
                  '(gregorian: ${g.year}/${g.month}/${g.day})',
            );
          }
        }
      }
    });
  });

  group('اعتبارسنجی ورودی', () {
    test('سال خارج از بازه → RangeError', () {
      expect(() => jalaliToGregorian(4000, 1, 1), throwsRangeError);
      expect(() => isLeapJalaliYear(-100), throwsRangeError);
    });

    test('ماه نامعتبر → RangeError', () {
      expect(() => jalaliToGregorian(1403, 0, 1), throwsRangeError);
      expect(() => jalaliToGregorian(1403, 13, 1), throwsRangeError);
    });

    test('روز نامعتبر → RangeError', () {
      expect(() => jalaliToGregorian(1403, 1, 0), throwsRangeError);
      expect(() => jalaliToGregorian(1403, 1, 32), throwsRangeError);
      // ۱۴۰۲ غیرکبیسه: اسفند ۲۹ روز است، روز ۳۰ نباید قبول شود
      expect(() => jalaliToGregorian(1402, 12, 30), throwsRangeError);
      // ۱۴۰۳ کبیسه: اسفند ۳۰ روز است، روز ۳۰ باید قبول شود
      expect(() => jalaliToGregorian(1403, 12, 30), returnsNormally);
    });
  });
}