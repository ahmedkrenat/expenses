
import 'package:expenses/data/constants.dart';
import 'package:flutter/material.dart';

class SignInIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Constants.signInIconPath,
      width: 150,
      height: 150,
    );
  }
}

class SignInText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      Constants.signInText,
      style: Constants.signInTextStyle,
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  GoogleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset(
        Constants.signInButtonIconPath,
        width: 30,
        height: 30,
      ),
      onPressed: onPressed,
    );
  }
}
