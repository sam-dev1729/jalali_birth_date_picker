// test/formatter_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:jalali_birth_date_picker/src/core/formatter.dart';
import 'package:jalali_birth_date_picker/src/models/jalali.dart';

void main() {
  final date = Jalali(1403, 1, 5);

  group('formatJalali', () {
    test('yyyy/MM/dd', () {
      expect(formatJalali(date, 'yyyy/MM/dd'), '1403/01/05');
    });

    test('yyyy-MM-dd', () {
      expect(formatJalali(date, 'yyyy-MM-dd'), '1403-01-05');
    });

    test('dd/MM/yyyy', () {
      expect(formatJalali(date, 'dd/MM/yyyy'), '05/01/1403');
    });

    test('yyyy', () {
      expect(formatJalali(date, 'yyyy'), '1403');
    });

    test('yy', () {
      expect(formatJalali(date, 'yy'), '03');
      expect(formatJalali(Jalali(1300, 1, 1), 'yy'), '00');
      expect(formatJalali(Jalali(1305, 1, 1), 'yy'), '05');
    });

    test('M و d تک‌رقمی', () {
      expect(formatJalali(date, 'yyyy/M/d'), '1403/1/5');
    });

    test('MMMM نام کامل ماه', () {
      expect(formatJalali(date, 'MMMM'), 'فروردین');
      expect(formatJalali(Jalali(1403, 12, 1), 'MMMM'), 'اسفند');
    });

    test('ترکیب نام ماه و سال', () {
      expect(formatJalali(date, 'd MMMM yyyy'), '5 فروردین 1403');
    });

    test('کاراکترهای غیرتوکن حفظ می‌شوند', () {
      expect(formatJalali(date, 'yyyy/MM/dd ساعت'), '1403/01/05 ساعت');
    });

    test('persianDigits', () {
      expect(
        formatJalali(date, 'yyyy/MM/dd', persianDigits: true),
        '۱۴۰۳/۰۱/۰۵',
      );
    });
  });

  group('toPersianDigits', () {
    test('تبدیل ارقام', () {
      expect(toPersianDigits('0123456789'), '۰۱۲۳۴۵۶۷۸۹');
    });

    test('کاراکترهای غیررقمی دست‌نخورده', () {
      expect(toPersianDigits('1403/01/05'), '۱۴۰۳/۰۱/۰۵');
      expect(toPersianDigits('abc'), 'abc');
    });
  });

  group('toLatinDigits', () {
    test('تبدیل ارقام فارسی', () {
      expect(toLatinDigits('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
    });

    test('تبدیل ارقام عربی', () {
      expect(toLatinDigits('٠١٢٣٤٥٦٧٨٩'), '0123456789');
    });

    test('کاراکترهای غیررقمی دست‌نخورده', () {
      expect(toLatinDigits('۱۴۰۳/۰۱/۰۵'), '1403/01/05');
    });
  });
}