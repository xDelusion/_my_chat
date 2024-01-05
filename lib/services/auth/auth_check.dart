import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/services/auth/login_or_register.dart';
import 'package:my_chat/pages/home_page.dart';

class AuthCheck extends StatelessWidget {
  AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            // it will listen to any authStateChanges() changes
            // checking if the user is logged in or not
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              return snapshot.hasData // if user is logged in

                  ? HomePage() // show the home page

                  : LoginOrRegister(); // if not ... show the login page
            }));
  }
}
