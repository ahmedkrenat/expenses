import 'package:expenses/app/utils/page_navigation.dart';
import 'package:expenses/app/widgets/signin/sign_in_widget.dart';
import 'package:expenses/data/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expenses/app/pages//home/home_page.dart';
import 'package:expenses/app/utils/snackbar.dart';
import 'package:expenses/data/repositories/authentication/google_signin.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.signInText),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SignInIcon(),
            SizedBox(height: 50),
            SignInText(),
            _isSigningIn
                ? CircularProgressIndicator()
                : GoogleSignInButton(
              onPressed: () async {
                setState(() {
                  _isSigningIn = true;
                });
                User? user = await GoogleSignin.signInWithGoogle(context);
                if (user != null) {
                  SnackBarHelper.successSnackBar(context, Constants.signedInSuccessfully);
                  navigateToPage(context, HomePage(user: user));
                } else {
                  setState(() {
                    _isSigningIn = false;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}


