import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/screens/auth/info_wrapper.dart';
import 'package:flutter_auth/screens/auth/welcome_screen.dart';
import 'package:flutter_auth/screens/home_screen.dart';

class AuthWrapper extends StatefulWidget {
  static String authWrapper = 'authWrapper';
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final autStream = FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: autStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Text('Somthing went wrong.');
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const UserInfoWrapper();
        }

        return const WelcomeScreen();
      },
    );
  }
}

class UserInfoWrapper extends StatefulWidget {
  const UserInfoWrapper({super.key});

  @override
  State<UserInfoWrapper> createState() => _UserInfoWrapperState();
}

class _UserInfoWrapperState extends State<UserInfoWrapper> {
  final autStream = FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: autStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Text('Somthing went wrong.');
        }

        if (snapshot.hasData) {
          if (snapshot.data?.isAnonymous == true) {
            return const HomeScreen();
          }
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const InfoWrapper();
        }

        return const WelcomeScreen();
      },
    );
  }
}
