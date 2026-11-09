# Changelog

## 0.1.0 — Initial release

### Added
- `JalaliBirthDateFormField` — `FormField` with age validation for registration forms.
- `JalaliBirthDatePicker` — inline picker widget.
- `showJalaliBirthDatePicker` — dialog helper.
- `Jalali` — dependency-free immutable date model with `addYears`, `addDays`, `compareTo`, `persianWeekday`, `toDateTime`, `fromDateTime`.
- `JalaliDateResult` — dual Jalali/Gregorian selection output.
- `formatJalali` — token-based formatter with Persian digit support.
- `JalaliDatePickerTheme` — lightweight theme override.
- RTL layout with Saturday-first week ordering.
- 100+ unit and widget tests, including full round-trip over Jalali years 1300–1450.

### Notes
- Zero runtime dependencies.
- The Jalali↔Gregorian converter is a faithful Dart port of [jalaali-js](https://github.com/jalaali/jalaali-js).