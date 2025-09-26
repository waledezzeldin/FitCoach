import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = true;
  bool saving = false;
  String? error;

  final nameCtrl = TextEditingController();
  final genderCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final heightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final p = await UserService().getProfile();
      nameCtrl.text = (p['name'] ?? '').toString();
      genderCtrl.text = (p['gender'] ?? '').toString();
      weightCtrl.text = (p['weight'] ?? '').toString();
      heightCtrl.text = (p['height'] ?? '').toString();
    } catch (e) {
      error = 'Failed to load profile';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { saving = true; error = null; });
    try {
      await UserService().updateProfile({
        'name': nameCtrl.text.trim(),
        'gender': genderCtrl.text.trim(),
        'weight': double.tryParse(weightCtrl.text.trim()),
        'height': double.tryParse(heightCtrl.text.trim()),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.pop(context);
    } catch (e) {
      setState(() => error = 'Failed to update profile');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    genderCtrl.dispose();
    weightCtrl.dispose();
    heightCtrl.dispose();
    super.dispose();
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
      appBar: AppBar(title: const Text('Edit Profile'), backgroundColor: Colors.black, foregroundColor: green),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (error != null) ...[
                      Text(error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: deco('Full name'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: genderCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: deco('Gender'),
                    ),
                    TextFormField(
                      controller: weightCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: deco('Weight (kg)'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: heightCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: deco('Height (cm)'),
                      keyboardType: TextInputType.number,
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
