
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'new_expense_dialog.dart';

class NewExpenseButton extends StatelessWidget {
  final User user;

  NewExpenseButton({required this.user});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        showDialog(
          context: context,
          builder: (context) {
            return  NewExpenseDialog(user: user);
          },
        );
      },
      child: Icon(Icons.add),
    );
  }
}