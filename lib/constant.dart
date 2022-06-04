import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const double kBottomSheetHeight = 470;
const double kBodyPadding = 16;
const double kRadius = 10;
const Color kDisbaledColor = Colors.black45;
const Color kBlue = Colors.blue;
Color kGreyLight = Colors.grey.shade200;

// Spacing between the content (widgets).
const double kContentSpacing8 = 8;
const double kContentSpacing32 = 32;
const double kCardHeight = 60;

Future<void> kShowSnackbar({
  required BuildContext context,
  required String message,
}) async {
  final snackBar = SnackBar(content: Text(message));

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

FirebaseException kConnectionException = FirebaseException(
  plugin: 'InternetConnectionChecker',
  code: 'no-connection',
  message: 'No network connection.',
);
