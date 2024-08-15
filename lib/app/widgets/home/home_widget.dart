

import 'package:expenses/app/pages/signin/sign_in_page.dart';
import 'package:expenses/app/utils/page_navigation.dart';
import 'package:expenses/app/widgets/home/home_expenses_tab.dart';
import 'package:expenses/app/widgets/home/sign_out_button.dart';
import 'package:expenses/data/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_analytics_tab.dart';

class HomePageWidget extends StatelessWidget{
  final User user;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  HomePageWidget({required this.user});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.monetization_on)),
              Tab(icon: Icon(Icons.analytics_rounded)),
            ],
          ),
          actions: [
            SignOutButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await _googleSignIn.signOut();
                navigateToPage(context, SignInPage());
              },
            ),
          ],
          title: Text(Constants.homeText),
        ),
        body: TabBarView(
          children: [
            ExpensesListViewer(user: user,),
            MonthlyExpenseStatistics(user: user,),
          ],
        ),
      ),
    );

  }

}