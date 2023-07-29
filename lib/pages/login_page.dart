import 'package:flutter/material.dart';
import 'package:spotless/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static String pageRoute = "/login";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Column(
        children: [
          TextField(controller: usernameController),
          TextField(controller: passwordController),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, HomePage.pageRoute);
            },
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }
}
