import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String oldPassword = '';
  String newPassword = '';
  String retypePassword = '';
  bool isLoading = false;
  String? error;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        // TODO: Send password change request to backend
        // await Dio().post('http://localhost:3000/change_password', data: {...});
        Navigator.pop(context);
      } catch (e) {
        setState(() => error = 'Failed to change password');
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (error != null)
                  Text(error!, style: const TextStyle(color: Colors.red)),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Old Password',
                    labelStyle: TextStyle(color: green),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: green),
                    ),
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  validator: (val) => val == null || val.isEmpty ? 'Old password is required' : null,
                  onChanged: (val) => setState(() => oldPassword = val),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: green),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: green),
                    ),
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  validator: (val) => val == null || val.isEmpty ? 'New password is required' : null,
                  onChanged: (val) => setState(() => newPassword = val),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Retype New Password',
                    labelStyle: TextStyle(color: green),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: green),
                    ),
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  validator: (val) => val != newPassword ? 'Passwords do not match' : null,
                  onChanged: (val) => setState(() => retypePassword = val),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading ? const CircularProgressIndicator() : const Text('Change Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}