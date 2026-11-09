// example/lib/main.dart

import 'package:flutter/material.dart';
import 'package:jalali_birth_date_picker/jalali_birth_date_picker.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'jalali_birth_date_picker demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      locale: const Locale('fa', 'IR'),
      home: const RegistrationScreen(),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  JalaliDateResult? _birthDate;
  String? _submitted;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final b = _birthDate!;
    final g = b.gregorian;
    setState(() {
      _submitted =
          'شمسی: ${formatJalali(b.jalali, "yyyy/MM/dd", persianDigits: true)}\n'
          'میلادی: ${g.year}-'
          '${g.month.toString().padLeft(2, '0')}-'
          '${g.day.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('ثبت‌نام')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'نام و نام خانوادگی',
                  ),
                ),
                const SizedBox(height: 16),
                JalaliBirthDateFormField(
                  minAge: 18,
                  maxAge: 100,
                  validator: (v) {
                    if (v == null) return 'تاریخ تولد را انتخاب کنید';
                    return null;
                  },
                  onChangedDate: (v) => setState(() => _birthDate = v),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('ثبت‌نام'),
                ),
                if (_submitted != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _submitted!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'نمونهٔ inline:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                JalaliBirthDatePicker(
                  minAge: 18,
                  maxAge: 100,
                  onChanged: (r) => setState(() => _birthDate = r),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
