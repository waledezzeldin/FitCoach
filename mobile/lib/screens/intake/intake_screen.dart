import 'package:flutter/material.dart';

class IntakeScreen extends StatefulWidget {
  const IntakeScreen({super.key});

  @override
  State<IntakeScreen> createState() => _IntakeScreenState();
}

class _IntakeScreenState extends State<IntakeScreen> {
  String goal = '';
  String experience = '';
  String injuries = '';
  String allergies = '';
  String meds = '';
  String diet = '';
  String budget = '';
  String age = '';
  String weight = '';
  String height = '';
  String gender = '';
  String trainingLocation = '';

  @override
  Widget build(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Intake Questionnaire'),
        backgroundColor: Colors.black,
        foregroundColor: green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Goal',
                labelStyle: TextStyle(color: green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: green),
                ),
              ),
              dropdownColor: Colors.black,
              items: ['Fat Loss', 'Muscle Gain', 'Wellness']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g, style: TextStyle(color: green))))
                  .toList(),
              onChanged: (val) => setState(() => goal = val ?? ''),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Experience Level',
                labelStyle: TextStyle(color: green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: green),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => experience = val,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Injuries/Contraindications',
                labelStyle: TextStyle(color: green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: green),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => injuries = val,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Allergies',
                labelStyle: TextStyle(color: green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: green),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => allergies = val,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Medications',
                labelStyle: TextStyle(color: green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: green),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => meds = val,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Dietary Preferences',
                labelStyle: TextStyle(color: green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: green),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => diet = val,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Budget',
                labelStyle: TextStyle(color: green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: green),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => budget = val,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Age',
                labelStyle: TextStyle(color: green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: green),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => age = val,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Weight',
                labelStyle: TextStyle(color: green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: green),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => weight = val,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Height',
                labelStyle: TextStyle(color: green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: green),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => height = val,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Gender',
                labelStyle: TextStyle(color: green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: green),
                ),
              ),
              dropdownColor: Colors.black,
              items: ['Male', 'Female', 'Other']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g, style: TextStyle(color: green))))
                  .toList(),
              onChanged: (val) => setState(() => gender = val ?? ''),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Training Location',
                labelStyle: TextStyle(color: green),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: green),
                ),
              ),
              dropdownColor: Colors.black,
              items: ['Home', 'Gym']
                  .map((loc) => DropdownMenuItem(value: loc, child: Text(loc, style: TextStyle(color: green))))
                  .toList(),
              onChanged: (val) => setState(() => trainingLocation = val ?? ''),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Send intake data to backend
                // Navigator.pushReplacementNamed(context, '/dashboard');
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}