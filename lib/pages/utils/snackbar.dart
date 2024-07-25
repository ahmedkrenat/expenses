import 'package:flutter/material.dart';

class SnackBarHelper {
  static void failureSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 5), // Duration of the SnackBar
        backgroundColor: Colors.red, // Background color of the SnackBar
        behavior: SnackBarBehavior.floating, // Make the SnackBar float
      ),
    );
  }

  static void successSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // Duration of the SnackBar
        backgroundColor: Colors.green, // Background color of the SnackBar
        behavior: SnackBarBehavior.floating, // Make the SnackBar float
      ),
    );
  }

}
