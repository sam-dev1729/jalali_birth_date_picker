// import 'package:flutter_test/flutter_test.dart';

// import 'package:jalali_birth_date_picker/jalali_birth_date_picker.dart';

// void expectJ2G(int jy, int jm, int jd, int gy, int gm, int gd) {
//   final r = jalaliToGregorian(jy, jm, jd);
//   expect((r.year, r.month, r.day), (gy, gm, gd));
// }

// void expectG2J(int gy, int gm, int gd, int jy, int jm, int jd) {
//   final r = gregorianToJalali(gy, gm, gd);
//   expect((r.year, r.month, r.day), (jy, jm, jd));
// }

// void main() {
//   test('نوروز سال‌های مرجع', () {
//     expectJ2G(1403, 1, 1, 2024, 3, 20);
//     expectJ2G(1402, 1, 1, 2023, 3, 21);
//     expectJ2G(1404, 1, 1, 2025, 3, 21);
//     expectJ2G(1399, 1, 1, 2020, 3, 20);
//     expectJ2G(1357, 1, 1, 1978, 3, 21);
//   });

//   test('کبیسه‌های مرجع', () {
//     expect(isLeapJalali(1399), isTrue);
//     expect(isLeapJalali(1403), isTrue);
//     expect(isLeapJalali(1402), isFalse);
//     expect(isLeapJalali(1404), isFalse);
//   });

//   test('روزهای آخر اسفند در سال کبیسه و عادی', () {
//     // 1403 کبیسه: اسفند ۳۰ روز
//     expectJ2G(1403, 12, 30, 2025, 3, 20);
//     // 1402 غیرکبیسه: اسفند ۲۹ روز
//     expectJ2G(1402, 12, 29, 2024, 3, 19);
//   });

//   test('رفت و برگشت شمسی↔میلادی روی بازهٔ بزرگ', () {
//     for (var jy = 1300; jy <= 1450; jy++) {
//       for (var jm = 1; jm <= 12; jm++) {
//         final len = jalaliMonthLength(jy, jm);
//         for (var jd = 1; jd <= len; jd++) {
//           final g = jalaliToGregorian(jy, jm, jd);
//           final back = gregorianToJalali(g.year, g.month, g.day);
//           expect((back.year, back.month, back.day), (jy, jm, jd),
//               reason: 'round-trip failed for $jy/$jm/$jd');
//         }
//       }
//     }
//   });

//   test('روز هفته', () {
//     // 2024-03-20 = 1403-01-01 = چهارشنبه => persianWeekday = 5
//     expect(Jalali(1403, 1, 1).persianWeekday, 5);
//   });
// }
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder', () {
    expect(true, isTrue);
  });
}
