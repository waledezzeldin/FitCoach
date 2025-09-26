import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String current = '';
  String next = '';
  String confirm = '';
  bool saving = false;
  String? error;
  String? info;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { saving = true; error = null; info = null; });
    try {
      await UserService().changePassword(currentPassword: current, newPassword: next);
      setState(() => info = 'Password changed');
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => error = 'Failed to change password');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    InputDecoration deco(String label) => InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: green),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: green.withOpacity(0.5))),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: green)),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Change Password'), backgroundColor: Colors.black, foregroundColor: green),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
              if (info != null) Text(info!, style: TextStyle(color: green)),
              TextFormField(
                decoration: deco('Current password'),
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => current = v,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                decoration: deco('New password'),
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => next = v,
                validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
              ),
              TextFormField(
                decoration: deco('Confirm new password'),
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => confirm = v,
                validator: (v) => (v != next) ? 'Does not match' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}