import 'package:flutter/material.dart';
import 'package:my_chat/services/auth/auth_service.dart';
import 'package:my_chat/components/my_button.dart';
import 'package:my_chat/components/my_textfield.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // tap to go to register page
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  void login(BuildContext context) async {
    final authService = AuthService();

    try {
      await authService.userLogin(
          _emailController.text, _passwordController.text);
    } catch (error) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 50),
            Text("Welcome back, you've been missed!",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16)),
            SizedBox(height: 25),
            MyTextField(
              controller: _emailController,
              obscureText: false,
              hintText: "Email",
            ),
            SizedBox(height: 10),
            MyTextField(
              controller: _passwordController,
              obscureText: true,
              hintText: "Password",
            ),
            SizedBox(height: 25),
            MyButton(
              // onTap: login,
              onTap: () => login(context),
              text: "Login",
            ),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a user? ",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Register",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
