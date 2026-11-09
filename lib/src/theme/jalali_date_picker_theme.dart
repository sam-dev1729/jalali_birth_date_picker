// lib/src/theme/jalali_date_picker_theme.dart

import 'package:flutter/material.dart';

/// تم سبک برای [JalaliBirthDatePicker] و ویجت‌های وابسته.
///
/// همهٔ فیلدها nullable هستند، تا بتوانی فقط بخشی را override کنی.
/// برای پیش‌فرض‌های سازگار با Material 3 از [JalaliDatePickerTheme.of]
/// استفاده کن.
@immutable
class JalaliDatePickerTheme {
  const JalaliDatePickerTheme({
    this.backgroundColor,
    this.selectedDayColor,
    this.selectedDayTextColor,
    this.todayBorderColor,
    this.disabledDayColor,
    this.weekendDayColor,
    this.weekdayTextStyle,
    this.dayTextStyle,
    this.selectedDayTextStyle,
    this.disabledDayTextStyle,
    this.monthYearTextStyle,
    this.navigationIconColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.cellSpacing = 4.0,
    this.cellHeight = 40.0,
    this.headerHeight = 32.0,
  });

  final Color? backgroundColor;
  final Color? selectedDayColor;
  final Color? selectedDayTextColor;
  final Color? todayBorderColor;
  final Color? disabledDayColor;
  final Color? weekendDayColor;
  final TextStyle? weekdayTextStyle;
  final TextStyle? dayTextStyle;
  final TextStyle? selectedDayTextStyle;
  final TextStyle? disabledDayTextStyle;
  final TextStyle? monthYearTextStyle;
  final Color? navigationIconColor;
  final BorderRadius borderRadius;
  final double cellSpacing;
  final double cellHeight;
  final double headerHeight;

  /// پیش‌فرض‌های Material 3 بر اساس [Theme] فعلی.
  static JalaliDatePickerTheme of(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return JalaliDatePickerTheme(
      backgroundColor: cs.surface,
      selectedDayColor: cs.primary,
      selectedDayTextColor: cs.onPrimary,
      todayBorderColor: cs.primary,
      disabledDayColor: cs.onSurface.withValues(alpha: 0.3),
      weekendDayColor: cs.error,
      weekdayTextStyle: tt.bodySmall,
      dayTextStyle: tt.bodyMedium,
      monthYearTextStyle: tt.titleMedium,
      navigationIconColor: cs.onSurface,
    );
  }

  /// ادغام با تم دیگر: هر فیلد غیرnull در [other] اولویت دارد.
  JalaliDatePickerTheme merge(JalaliDatePickerTheme? other) {
    if (other == null) return this;
    return JalaliDatePickerTheme(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      selectedDayColor: other.selectedDayColor ?? selectedDayColor,
      selectedDayTextColor: other.selectedDayTextColor ?? selectedDayTextColor,
      todayBorderColor: other.todayBorderColor ?? todayBorderColor,
      disabledDayColor: other.disabledDayColor ?? disabledDayColor,
      weekendDayColor: other.weekendDayColor ?? weekendDayColor,
      weekdayTextStyle: other.weekdayTextStyle ?? weekdayTextStyle,
      dayTextStyle: other.dayTextStyle ?? dayTextStyle,
      selectedDayTextStyle: other.selectedDayTextStyle ?? selectedDayTextStyle,
      disabledDayTextStyle: other.disabledDayTextStyle ?? disabledDayTextStyle,
      monthYearTextStyle: other.monthYearTextStyle ?? monthYearTextStyle,
      navigationIconColor: other.navigationIconColor ?? navigationIconColor,
      borderRadius: other.borderRadius,
      cellSpacing: other.cellSpacing,
      cellHeight: other.cellHeight,
      headerHeight: other.headerHeight,
    );
  }
}
