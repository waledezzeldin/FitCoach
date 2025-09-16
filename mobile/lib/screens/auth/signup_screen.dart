import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final api = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await api.signup(emailController.text, passController.text);
                  Navigator.pushReplacementNamed(context, "/login");
                } catch (e) {
                  print("Signup failed: $e");
                }
              },
              child: Text("Create Account"),
            )
          ],
        ),
      ),
    );
  }
}

class ApiService {
  // Add your API methods here

  Future<void> signup(String email, String password) async {
    // TODO: Implement your signup logic here, e.g., send HTTP request to backend
    // For now, just simulate a network call
    await Future.delayed(Duration(seconds: 1));
    // Throw an error if needed, or return normally
  }
}
