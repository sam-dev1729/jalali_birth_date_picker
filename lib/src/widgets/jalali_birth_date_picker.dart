// lib/src/widgets/jalali_birth_date_picker.dart

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/formatter.dart';
import '../models/jalali.dart';
import '../models/jalali_date_result.dart';
import '../theme/jalali_date_picker_theme.dart';
import 'jalali_calendar_grid.dart';

/// ویجت inline انتخاب تاریخ تولد شمسی.
class JalaliBirthDatePicker extends StatefulWidget {
  const JalaliBirthDatePicker({
    super.key,
    required this.onChanged,
    this.initialDate,
    this.minAge = 18,
    this.maxAge = 100,
    this.usePersianDigits = true,
    this.theme,
    this.today,
  })  : assert(minAge >= 0),
        assert(maxAge >= minAge, 'maxAge must be >= minAge');

  final ValueChanged<JalaliDateResult> onChanged;
  final Jalali? initialDate;
  final int minAge;
  final int maxAge;
  final bool usePersianDigits;
  final JalaliDatePickerTheme? theme;
  final Jalali? today;

  @override
  State<JalaliBirthDatePicker> createState() => _JalaliBirthDatePickerState();
}

class _JalaliBirthDatePickerState extends State<JalaliBirthDatePicker> {
  late Jalali _displayMonth;
  Jalali? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _displayMonth = _initialDisplayMonth();
  }

  Jalali get _today => widget.today ?? Jalali.now();

  Jalali get _firstSelectable => _today.addYears(-widget.maxAge);
  Jalali get _lastSelectable => _today.addYears(-widget.minAge);

  Jalali _initialDisplayMonth() {
    if (_selected != null) return _selected!.firstDayOfMonth;
    final candidate = _today.addYears(-25);
    if (candidate.isBefore(_firstSelectable)) {
      return _firstSelectable.firstDayOfMonth;
    }
    if (candidate.isAfter(_lastSelectable)) {
      return _lastSelectable.firstDayOfMonth;
    }
    return candidate.firstDayOfMonth;
  }

  void _onDaySelected(Jalali date) {
    setState(() => _selected = date);
    widget.onChanged(JalaliDateResult.fromJalali(date));
  }

  void _prevMonth() {
    setState(() {
      final month = _displayMonth.month;
      final year = _displayMonth.year;
      _displayMonth =
          month == 1 ? Jalali(year - 1, 12, 1) : Jalali(year, month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      final month = _displayMonth.month;
      final year = _displayMonth.year;
      _displayMonth =
          month == 12 ? Jalali(year + 1, 1, 1) : Jalali(year, month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = JalaliDatePickerTheme.of(context).merge(widget.theme);
    final monthName = jalaliMonthNames[_displayMonth.month - 1];
    final yearText = widget.usePersianDigits
        ? toPersianDigits(_displayMonth.year.toString())
        : _displayMonth.year.toString();

    return Container(
      decoration: BoxDecoration(
        color: t.backgroundColor,
        borderRadius: t.borderRadius,
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_right, color: t.navigationIconColor),
                onPressed: _prevMonth,
                tooltip: 'ماه قبل',
              ),
              Text('$monthName $yearText', style: t.monthYearTextStyle),
              IconButton(
                icon: Icon(Icons.chevron_left, color: t.navigationIconColor),
                onPressed: _nextMonth,
                tooltip: 'ماه بعد',
              ),
            ],
          ),
          JalaliCalendarGrid(
            displayMonth: _displayMonth,
            selected: _selected,
            firstSelectable: _firstSelectable,
            lastSelectable: _lastSelectable,
            onDaySelected: _onDaySelected,
            usePersianDigits: widget.usePersianDigits,
            theme: t,
            today: _today,
          ),
        ],
      ),
    );
  }
}

/// نمایش [JalaliBirthDatePicker] در یک دیالوگ با دکمه‌های «انصراف» و «تایید».
Future<JalaliDateResult?> showJalaliBirthDatePicker({
  required BuildContext context,
  Jalali? initialDate,
  int minAge = 18,
  int maxAge = 100,
  bool usePersianDigits = true,
  JalaliDatePickerTheme? theme,
  Jalali? today,
}) {
  JalaliDateResult? result;
  return showDialog<JalaliDateResult>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              JalaliBirthDatePicker(
                onChanged: (r) => setState(() => result = r),
                initialDate: initialDate,
                minAge: minAge,
                maxAge: maxAge,
                usePersianDigits: usePersianDigits,
                theme: theme,
                today: today,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('انصراف'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: result == null
                        ? null
                        : () => Navigator.of(ctx).pop(result),
                    child: const Text('تایید'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
