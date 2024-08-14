import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/app/widgets/home/home_widget.dart';
import 'package:expenses/app/widgets/home/new_expense_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final User user;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  HomePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomePageWidget(user: user,),
      floatingActionButton: NewExpenseButton(user: user,),
    );
  }
}
