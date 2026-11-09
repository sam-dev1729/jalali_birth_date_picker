# jalali_birth_date_picker

A dependency-free Jalali (Persian) birth date picker for Flutter registration forms. Built for the case that most Persian date pickers ignore: **collecting a birth date with age validation**.

- 🎂 **Age validation built-in** — pass `minAge: 18` and `maxAge: 100`; disabled dates are handled for you.
- 🔁 **Dual output** — every selection yields both a `Jalali` (for display) and a `DateTime` (for your backend).
- 📝 **Real `FormField`** — works with `Form`, `validator`, and `TextFormField`-style layouts.
- 🌐 **RTL-first** — layout, weekday order, and Persian digits are correct by default.
- 📦 **Zero dependencies** — no `intl`, no `shamsi_date`, no native code.
- 🧪 **Tested** — 100+ unit and widget tests, including a full round-trip over Jalali years 1300–1450.

---

## Install

```yaml
dependencies:
  jalali_birth_date_picker: ^0.1.0



Quick start
dart
import 'package:jalali_birth_date_picker/jalali_birth_date_picker.dart';

Form(
  key: _formKey,
  child: Column(
    children: [
      JalaliBirthDateFormField(
        minAge: 18,
        maxAge: 100,
        validator: (v) => v == null ? 'تاریخ تولد را انتخاب کنید' : null,
        onChangedDate: (result) {
          // result.jalali    → Jalali(1370, 5, 12)
          // result.gregorian → DateTime(1991, 8, 3)
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Submit result.gregorian to your backend.
          }
        },
        child: const Text('ثبت‌نام'),
      ),
    ],
  ),
)
The field opens showJalaliBirthDatePicker in a dialog. For an inline layout, use the widget directly:

dart
JalaliBirthDatePicker(
  minAge: 18,
  maxAge: 100,
  onChanged: (result) => print(result.gregorian),
)
Why this package?
Most Persian date pickers on pub.dev are general-purpose. This one is narrow:

Feature	This package	General pickers
Age validation (minAge / maxAge)	✅ Built in	❌ You compute dates
Dual Jalali + Gregorian output	✅ One object	⚠️ Usually one or the other
Works as FormField with validator	✅ Yes	❌ Often custom widget
Zero dependencies	✅ Yes	❌ Depends on intl / shamsi_date
API
JalaliBirthDateFormField
The primary widget for registration forms.

Parameter	Type	Default	Description
minAge	int	18	Minimum accepted age.
maxAge	int	100	Maximum accepted age.
label	String	'تاریخ تولد'	Field label.
hint	String	'انتخاب تاریخ تولد'	Placeholder.
usePersianDigits	bool	true	Show ۰۱۲۳ vs 0123.
dateFormat	String	'yyyy/MM/dd'	Display format (see formatJalali).
theme	JalaliDatePickerTheme?	null	Color/text overrides.
decoration	InputDecoration?	null	Full InputDecoration override.
validator	FormFieldValidator?	null	Standard Form validator.
onChangedDate	ValueChanged<JalaliDateResult>?	null	Notified on selection.
today	Jalali?	Jalali.now()	Override "today" for testing.
JalaliBirthDatePicker
Inline picker (no dialog). Same age validation, plus:

Parameter	Type	Description
onChanged	ValueChanged<JalaliDateResult>	Required.
initialDate	Jalali?	Pre-selected date.
showJalaliBirthDatePicker
dart
Future<JalaliDateResult?> showJalaliBirthDatePicker({
  required BuildContext context,
  Jalali? initialDate,
  int minAge = 18,
  int maxAge = 100,
  bool usePersianDigits = true,
  JalaliDatePickerTheme? theme,
});
JalaliDateResult
dart
class JalaliDateResult {
  final Jalali jalali;      // For display
  final DateTime gregorian; // For backend
}
JalaliDatePickerTheme
Lightweight override object. All fields nullable; unspecified ones fall back to Material 3 defaults:

dart
JalaliBirthDatePicker(
  theme: const JalaliDatePickerTheme(
    selectedDayColor: Colors.deepPurple,
    weekendDayColor: Colors.red,
    borderRadius: BorderRadius.all(Radius.circular(16)),
  ),
  onChanged: (r) {},
)
Direct use of the date model
The package also exposes its pure-Dart core, useful outside widgets:

dart
import 'package:jalali_birth_date_picker/jalali_birth_date_picker.dart';

final birth = Jalali(1370, 5, 12);
print(formatJalali(birth, 'd MMMM yyyy', persianDigits: true));
// ۱۲ مرداد ۱۳۷۰

final back = Jalali.fromDateTime(DateTime(1991, 8, 3));
print(back == birth); // true

print(birth.addYears(18)); // Jalali(1388, 5, 12)
Supported range
The underlying converter supports Jalali years -61 to 3177. Outside this range, RangeError is thrown. For registration forms (18–100 years), this is far more than enough.

Example
A full registration form lives in example/. Run:

bash
cd example
flutter run