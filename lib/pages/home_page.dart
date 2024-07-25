import 'package:expenses/pages/sign_in_page.dart';
import 'package:expenses/pages/utils/page_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatelessWidget {
  final User user;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  HomePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await _googleSignIn.signOut();
              navigateToPage(context, SignInPage());
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome, ${user.displayName}!'),
      ),
    );
  }
}
