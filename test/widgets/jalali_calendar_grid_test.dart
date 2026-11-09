// test/widgets/jalali_calendar_grid_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jalali_birth_date_picker/jalali_birth_date_picker.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  testWidgets('هدر روزهای هفته رندر می‌شود', (tester) async {
    await tester.pumpWidget(_wrap(
      JalaliCalendarGrid(
        displayMonth: Jalali(1403, 1, 1),
        selected: null,
        firstSelectable: null,
        lastSelectable: null,
        onDaySelected: (_) {},
        today: Jalali(1403, 1, 1),
      ),
    ));
    for (final w in ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج']) {
      expect(find.text(w), findsOneWidget);
    }
  });

  testWidgets('۳۱ روز برای ماه ۱ رندر می‌شود (با ارقام فارسی)', (tester) async {
    await tester.pumpWidget(_wrap(
      JalaliCalendarGrid(
        displayMonth: Jalali(1403, 1, 1),
        selected: null,
        firstSelectable: null,
        lastSelectable: null,
        onDaySelected: (_) {},
        usePersianDigits: false,
        today: Jalali(1403, 1, 1),
      ),
    ));
    for (var d = 1; d <= 31; d++) {
      expect(find.text('$d'), findsOneWidget, reason: 'day $d');
    }
    expect(find.text('32'), findsNothing);
  });

  testWidgets('روز خارج از بازه غیرفعال است و tap نمی‌گیرد', (tester) async {
    Jalali? tapped;
    await tester.pumpWidget(_wrap(
      JalaliCalendarGrid(
        displayMonth: Jalali(1403, 1, 1),
        selected: null,
        firstSelectable: Jalali(1403, 1, 10),
        lastSelectable: Jalali(1403, 1, 20),
        onDaySelected: (d) => tapped = d,
        usePersianDigits: false,
        today: Jalali(1403, 1, 1),
      ),
    ));
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    expect(tapped, isNull);

    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    expect(tapped, Jalali(1403, 1, 15));
  });

  testWidgets('روز انتخاب‌شده با تم متمایز نمایش داده می‌شود', (tester) async {
    final theme = JalaliDatePickerTheme(
      selectedDayColor: const Color(0xFFFF0000),
    );
    await tester.pumpWidget(_wrap(
      JalaliCalendarGrid(
        displayMonth: Jalali(1403, 1, 1),
        selected: Jalali(1403, 1, 15),
        firstSelectable: null,
        lastSelectable: null,
        onDaySelected: (_) {},
        usePersianDigits: false,
        theme: theme,
        today: Jalali(1403, 1, 1),
      ),
    ));
    final material = tester.widget<Material>(
      find
          .ancestor(
            of: find.text('15'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color, const Color(0xFFFF0000));
  });
}