import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String email = '';
  String password = '';
  String name = '';
  String role = 'user'; // Default role

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (val) => setState(() => name = val),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (val) => setState(() => email = val),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (val) => setState(() => password = val),
            ),
            DropdownButton<String>(
              value: role,
              items: [
                DropdownMenuItem(value: 'user', child: Text('User')),
                DropdownMenuItem(value: 'coach', child: Text('Coach')),
              ],
              onChanged: (val) => setState(() => role = val!),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final response = await Dio().post(
                  'http://your-backend-url/v1/users/register',
                  data: {
                    'email': email,
                    'password': password,
                    'name': name,
                    'role': role,
                  },
                );
                if (role == 'coach') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coach request submitted. Await admin approval.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signup successful!')),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
