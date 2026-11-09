// test/grid_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:jalali_birth_date_picker/src/core/grid.dart';
import 'package:jalali_birth_date_picker/src/models/jalali.dart';

void main() {
  group('buildMonthGrid — ساختار پایه', () {
    test('طول خروجی همیشه مضرب ۷ است', () {
      for (final jy in [1402, 1403, 1404]) {
        for (var jm = 1; jm <= 12; jm++) {
          final grid = buildMonthGrid(Jalali(jy, jm, 1));
          expect(grid.length % 7, 0, reason: 'month $jy/$jm');
        }
      }
    });

    test('padTo6Weeks=true → همیشه ۴۲ خانه', () {
      for (final jy in [1402, 1403, 1404]) {
        for (var jm = 1; jm <= 12; jm++) {
          final grid = buildMonthGrid(Jalali(jy, jm, 1));
          expect(grid.length, 42, reason: 'month $jy/$jm');
        }
      }
    });

    test('padTo6Weeks=false → ۳۵ یا ۴۲ خانه', () {
      for (final jy in [1402, 1403, 1404]) {
        for (var jm = 1; jm <= 12; jm++) {
          final grid = buildMonthGrid(
            Jalali(jy, jm, 1),
            padTo6Weeks: false,
          );
          expect(
            grid.length,
            anyOf(35, 42),
            reason: 'month $jy/$jm length=${grid.length}',
          );
        }
      }
    });

    test('padTo6Weeks=false → 1402/12 (۵ ردیف) چون ۲۹ روز است', () {
      final grid = buildMonthGrid(
        Jalali(1402, 12, 1),
        padTo6Weeks: false,
      );
      expect(grid.length, 35);
    });

    test('خروجی غیرقابل تغییر (unmodifiable) است', () {
      final grid = buildMonthGrid(Jalali(1403, 1, 1));
      expect(() => grid.add(null), throwsUnsupportedError);
    });
  });

  group('buildMonthGrid — محتوا', () {
    test('همهٔ روزهای ماه حضور دارند', () {
      final grid = buildMonthGrid(Jalali(1403, 1, 1));
      final days = grid.whereType<Jalali>().toList();
      expect(days.length, 31);
      for (var d = 1; d <= 31; d++) {
        expect(
          days.contains(Jalali(1403, 1, d)),
          isTrue,
          reason: 'missing day $d',
        );
      }
    });

    test('روزهای ماه بعد یا قبل در خروجی نیستند', () {
      final grid = buildMonthGrid(Jalali(1403, 1, 1));
      for (final cell in grid.whereType<Jalali>()) {
        expect(cell.year, 1403);
        expect(cell.month, 1);
      }
    });

    test('روزها به ترتیب صعودی هستند', () {
      final grid = buildMonthGrid(Jalali(1403, 7, 1));
      final days = grid.whereType<Jalali>().toList();
      for (var i = 1; i < days.length; i++) {
        expect(days[i].isAfter(days[i - 1]), isTrue, reason: 'index $i');
      }
    });
  });

  group('buildMonthGrid — هم‌ترازی', () {
    test('1403/01/01 (چهارشنبه) → ۴ خانه خالی در ابتدا', () {
      final grid = buildMonthGrid(Jalali(1403, 1, 1));
      expect(grid.sublist(0, 4), everyElement(isNull));
      expect(grid[4], Jalali(1403, 1, 1));
    });

    test('1403/02/01 (شنبه) → ۰ خانه خالی در ابتدا', () {
      final grid = buildMonthGrid(Jalali(1403, 2, 1));
      expect(grid[0], Jalali(1403, 2, 1));
    });

    test('1403/04/01 (جمعه) → ۶ خانه خالی در ابتدا', () {
      final grid = buildMonthGrid(Jalali(1403, 4, 1));
      expect(grid.sublist(0, 6), everyElement(isNull));
      expect(grid[6], Jalali(1403, 4, 1));
    });

    test('خانه‌های بعد از آخرین روز، همه null هستند (1403/02، شنبه‌شروع)', () {
      final grid = buildMonthGrid(Jalali(1403, 2, 1));
      // 31 day + 0 leading = 31 cell real, rest null (42 total)
      for (var i = 31; i < 42; i++) {
        expect(grid[i], isNull, reason: 'index $i should be null');
      }
    });

    test('موقعیت روز اول = persianWeekday - 1 (روی همهٔ ماه‌های ۱۴۰۲–۱۴۰۴)',
        () {
      for (final jy in [1402, 1403, 1404]) {
        for (var jm = 1; jm <= 12; jm++) {
          final first = Jalali(jy, jm, 1);
          final grid = buildMonthGrid(first);
          final expectedIndex = first.persianWeekday - 1;
          expect(
            grid[expectedIndex],
            first,
            reason: 'month $jy/$jm, firstWeekday=${first.persianWeekday}',
          );
          for (var i = 0; i < expectedIndex; i++) {
            expect(grid[i], isNull, reason: 'month $jy/$jm index $i');
          }
        }
      }
    });
  });

  group('buildMonthGrid — کبیسه و غیرکبیسه', () {
    test('1403/12 (کبیسه) → ۳۰ روز، آخری 1403/12/30', () {
      final grid = buildMonthGrid(Jalali(1403, 12, 1));
      final days = grid.whereType<Jalali>().toList();
      expect(days.length, 30);
      expect(days.last, Jalali(1403, 12, 30));
    });

    test('1402/12 (غیرکبیسه) → ۲۹ روز، آخری 1402/12/29', () {
      final grid = buildMonthGrid(Jalali(1402, 12, 1));
      final days = grid.whereType<Jalali>().toList();
      expect(days.length, 29);
      expect(days.last, Jalali(1402, 12, 29));
    });
  });

  group('buildMonthGrid — طول ماه‌ها', () {
    test('ماه‌های ۱ تا ۶ → ۳۱ روز', () {
      for (var m = 1; m <= 6; m++) {
        final grid = buildMonthGrid(Jalali(1403, m, 1));
        expect(grid.whereType<Jalali>().length, 31, reason: 'month $m');
      }
    });

    test('ماه‌های ۷ تا ۱۱ → ۳۰ روز', () {
      for (var m = 7; m <= 11; m++) {
        final grid = buildMonthGrid(Jalali(1403, m, 1));
        expect(grid.whereType<Jalali>().length, 30, reason: 'month $m');
      }
    });
  });

  group('buildMonthGrid — ورودی از هر روز ماه', () {
    test('مستقل از روز ورودی، شبکه یکسان است', () {
      // buildMonthGrid باید از firstDayOfMonth استفاده کند، نه day ورودی
      final a = buildMonthGrid(Jalali(1403, 5, 1));
      final b = buildMonthGrid(Jalali(1403, 5, 17));
      final c = buildMonthGrid(Jalali(1403, 5, 31));
      expect(a, b);
      expect(b, c);
    });
  });
}
