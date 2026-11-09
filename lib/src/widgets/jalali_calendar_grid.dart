// lib/src/widgets/jalali_calendar_grid.dart

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/formatter.dart';
import '../core/grid.dart';
import '../models/jalali.dart';
import '../theme/jalali_date_picker_theme.dart';

/// گرید ماهانهٔ تقویم شمسی.
///
/// ستون اول همیشه شنبه است.
class JalaliCalendarGrid extends StatelessWidget {
  const JalaliCalendarGrid({
    super.key,
    required this.displayMonth,
    required this.selected,
    required this.firstSelectable,
    required this.lastSelectable,
    required this.onDaySelected,
    this.usePersianDigits = true,
    this.theme,
    this.today,
  });

  final Jalali displayMonth;
  final Jalali? selected;
  final Jalali? firstSelectable;
  final Jalali? lastSelectable;
  final ValueChanged<Jalali> onDaySelected;
  final bool usePersianDigits;
  final JalaliDatePickerTheme? theme;
  final Jalali? today;

  bool _isSelectable(Jalali d) {
    if (firstSelectable != null && d.isBefore(firstSelectable!)) return false;
    if (lastSelectable != null && d.isAfter(lastSelectable!)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final t = theme ?? JalaliDatePickerTheme.of(context);
    final cells = buildMonthGrid(displayMonth);
    final todayDate = today ?? Jalali.now();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Table(
        defaultColumnWidth: const FlexColumnWidth(),
        children: [
          TableRow(
            children: [
              for (final w in jalaliWeekdayShort)
                SizedBox(
                  height: t.headerHeight,
                  child: Center(
                    child: Text(w, style: t.weekdayTextStyle),
                  ),
                ),
            ],
          ),
          for (var week = 0; week < cells.length ~/ 7; week++)
            TableRow(
              children: [
                for (var d = 0; d < 7; d++)
                  _buildCell(
                    cells[week * 7 + d],
                    todayDate,
                    t,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCell(Jalali? date, Jalali today, JalaliDatePickerTheme t) {
    if (date == null) {
      return SizedBox(height: t.cellHeight);
    }
    return Padding(
      padding: EdgeInsets.all(t.cellSpacing / 2),
      child: SizedBox(
        height: t.cellHeight,
        child: _DayCell(
          date: date,
          isSelected: date == selected,
          isToday: date == today,
          isEnabled: _isSelectable(date),
          isWeekend: date.persianWeekday == 7,
          onTap: () => onDaySelected(date),
          usePersianDigits: usePersianDigits,
          theme: t,
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.isEnabled,
    required this.isWeekend,
    required this.onTap,
    required this.usePersianDigits,
    required this.theme,
  });

  final Jalali date;
  final bool isSelected;
  final bool isToday;
  final bool isEnabled;
  final bool isWeekend;
  final VoidCallback onTap;
  final bool usePersianDigits;
  final JalaliDatePickerTheme theme;

  @override
  Widget build(BuildContext context) {
    Color textColor;
    if (!isEnabled) {
      textColor = theme.disabledDayColor ?? const Color(0xFF9E9E9E);
    } else if (isSelected) {
      textColor = theme.selectedDayTextStyle?.color ??
          theme.selectedDayTextColor ??
          Colors.white;
    } else if (isWeekend) {
      textColor = theme.weekendDayColor ?? const Color(0xFFD32F2F);
    } else {
      textColor = theme.dayTextStyle?.color ?? const Color(0xFF212121);
    }

    final dayText = usePersianDigits
        ? toPersianDigits(date.day.toString())
        : date.day.toString();

    final bgColor = isSelected ? (theme.selectedDayColor ?? Colors.blue) : null;
    final border = (isToday && !isSelected)
        ? Border.all(color: theme.todayBorderColor ?? Colors.blue)
        : null;

    return Material(
      color: bgColor ?? Colors.transparent,
      borderRadius: theme.borderRadius,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: theme.borderRadius,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: border,
            borderRadius: theme.borderRadius,
          ),
          child: Text(
            dayText,
            style: (theme.dayTextStyle ?? const TextStyle()).copyWith(
              color: textColor,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
        ),
      ),
    );
  }
}
