import 'package:flutter/material.dart';
import 'package:my_chat/services/auth/auth_service.dart';
import 'package:my_chat/components/my_button.dart';
import 'package:my_chat/components/my_textfield.dart';
import 'package:my_chat/shared/colorful_prints.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // tap to go to login page
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  void register(BuildContext context) {
    final _authService = AuthService();

    try {
      (_passwordController.text == _confirmPasswordController.text)
          ? _authService.userRegister(
              _emailController.text, _passwordController.text)
          : (() {
              printError("Passwords don't match!");
              throw ("Passwords don't match!");
            })();
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.message,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 50),
              Text("Let's create an account for you!  :)",
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
              SizedBox(height: 10),
              MyTextField(
                controller: _confirmPasswordController,
                obscureText: true,
                hintText: "Confirm password",
              ),
              SizedBox(height: 25),
              MyButton(
                onTap: () => register(context),
                text: "Register",
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already a user? ",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      "Login",
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
      ),
    );
  }
}
