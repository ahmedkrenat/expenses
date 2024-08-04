import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/app/pages/signin/sign_in_page.dart';
import 'package:expenses/app/widgets/home/home_widgets.dart';
import 'package:expenses/app/utils/page_navigation.dart';
import 'package:expenses/data/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatelessWidget {
  final User user;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  HomePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.homeText),
        actions: [
          SignOutButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await _googleSignIn.signOut();
              navigateToPage(context, SignInPage());
            },
          ),
        ],
      ),
      body: ExpensesViewer(user: user,),
      floatingActionButton: NewExpenseButton(user: user,),
    );
  }
}
