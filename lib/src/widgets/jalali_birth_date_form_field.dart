// lib/src/widgets/jalali_birth_date_form_field.dart

import 'package:flutter/material.dart';

import '../core/formatter.dart';
import '../models/jalali.dart';
import '../models/jalali_date_result.dart';
import '../theme/jalali_date_picker_theme.dart';
import 'jalali_birth_date_picker.dart';

/// یک [FormField] آماده برای ثبت‌نام.
///
/// با لمس، [showJalaliBirthDatePicker] را باز می‌کند، مقدار انتخاب‌شده را
/// نگه می‌دارد، و از [Form] والد خطای اعتبارسنجی می‌گیرد.
class JalaliBirthDateFormField extends FormField<JalaliDateResult> {
  JalaliBirthDateFormField({
    super.key,
    super.initialValue,
    super.validator,
    this.minAge = 18,
    this.maxAge = 100,
    this.label = 'تاریخ تولد',
    this.hint = 'انتخاب تاریخ تولد',
    this.usePersianDigits = true,
    this.dateFormat = 'yyyy/MM/dd',
    this.theme,
    this.decoration,
    this.today,
    this.onChangedDate,
  }) : super(
          builder: (state) => _JalaliBirthDateFormFieldBody(
            state: state,
            minAge: minAge,
            maxAge: maxAge,
            label: label,
            hint: hint,
            usePersianDigits: usePersianDigits,
            dateFormat: dateFormat,
            theme: theme,
            decoration: decoration,
            today: today,
            onChangedDate: onChangedDate,
          ),
        );

  final int minAge;
  final int maxAge;
  final String label;
  final String hint;
  final bool usePersianDigits;
  final String dateFormat;
  final JalaliDatePickerTheme? theme;
  final InputDecoration? decoration;
  final Jalali? today;

  /// کال‌بک اختیاری برای دریافت مقدار در والد، بدون دسترسی به state.
  final ValueChanged<JalaliDateResult>? onChangedDate;
}

class _JalaliBirthDateFormFieldBody extends StatelessWidget {
  const _JalaliBirthDateFormFieldBody({
    required this.state,
    required this.minAge,
    required this.maxAge,
    required this.label,
    required this.hint,
    required this.usePersianDigits,
    required this.dateFormat,
    required this.theme,
    required this.decoration,
    required this.today,
    required this.onChangedDate,
  });

  final FormFieldState<JalaliDateResult> state;
  final int minAge;
  final int maxAge;
  final String label;
  final String hint;
  final bool usePersianDigits;
  final String dateFormat;
  final JalaliDatePickerTheme? theme;
  final InputDecoration? decoration;
  final Jalali? today;
  final ValueChanged<JalaliDateResult>? onChangedDate;

  @override
  Widget build(BuildContext context) {
    final shown = state.value?.jalali;
    final text = shown == null
        ? ''
        : formatJalali(shown, dateFormat, persianDigits: usePersianDigits);

    return InkWell(
      onTap: () async {
        final picked = await showJalaliBirthDatePicker(
          context: context,
          initialDate: shown,
          minAge: minAge,
          maxAge: maxAge,
          usePersianDigits: usePersianDigits,
          theme: theme,
          today: today,
        );
        if (picked != null && state.mounted) {
          state.didChange(picked);
          onChangedDate?.call(picked);
        }
      },
      child: InputDecorator(
        isEmpty: text.isEmpty,
        decoration: (decoration ?? InputDecoration(labelText: label)).copyWith(
          hintText: hint,
          errorText: state.errorText,
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}