import 'package:flutter/material.dart';

class CoachOnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Coach Onboarding')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Bio'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Certifications'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Submit coach onboarding info to backend
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}