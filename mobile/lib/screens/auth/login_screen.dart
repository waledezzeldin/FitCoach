import 'package:flutter/material.dart';
// Update the path below to the correct location if needed

class ApiService {
  // Add your API methods here

  Future<dynamic> login(String email, String password) async {
    // TODO: Implement actual API call logic here
    // For now, simulate a successful login response
    await Future.delayed(Duration(seconds: 1));
    return {'success': true, 'email': email};
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final ApiService api = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
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
                  final res = await api.login(emailController.text, passController.text);
                  print("Login success: $res");
                  Navigator.pushReplacementNamed(context, "/dashboard");
                } catch (e) {
                  print("Login failed: $e");
                }
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
