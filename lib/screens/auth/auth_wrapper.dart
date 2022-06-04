import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/constant.dart';
import 'package:flutter_auth/models/user_model.dart';
import 'package:flutter_auth/screens/auth/info_wrapper.dart';
import 'package:flutter_auth/screens/auth/profile_image_screen.dart';
import 'package:flutter_auth/screens/auth/welcome_screen.dart';
import 'package:flutter_auth/screens/edit_profile_screens/edit_bio_screen.dart';
import 'package:flutter_auth/screens/edit_profile_screens/edit_email_screen.dart';
import 'package:flutter_auth/screens/edit_profile_screens/edit_gender_screen.dart';
import 'package:flutter_auth/screens/edit_profile_screens/edit_name_screen.dart';
import 'package:flutter_auth/screens/home_screen.dart';
import 'package:flutter_auth/services/cloud_fire.dart';
import 'package:flutter_auth/services/fire_auth.dart';
import 'package:flutter_auth/services/fire_storage.dart';
import 'package:flutter_auth/utilities/image_picker.dart';
import 'package:flutter_auth/utilities/validators.dart';
import 'package:flutter_auth/widgets/dialog.dart';
import 'package:flutter_auth/widgets/textfield.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AuthWrapper extends StatefulWidget {
  static String authWrapper = 'authWrapper';
  const AuthWrapper({Key? key}) : super(key: key);

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
  const UserInfoWrapper({Key? key}) : super(key: key);

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

        if (snapshot.hasData && snapshot.data != null) {
          return const InfoWrapper();
        }

        return const WelcomeScreen();
      },
    );
  }
}
