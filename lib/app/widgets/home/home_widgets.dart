import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/data/constants.dart';
import 'package:expenses/data/repositories/database/cloud_firestore.dart';
import 'package:expenses/domain/entities/Expense.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignOutButton extends StatelessWidget {
  final VoidCallback onPressed;

  SignOutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.exit_to_app),
      onPressed: onPressed,
    );
  }
}

class ExpensesViewer extends StatelessWidget{
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final User user;

  ExpensesViewer({required this.user});

  @override
  Widget build(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: CloudFirestore.getExpensesStream(user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text(Constants.noExpensesFound));
        }

        List<Expense> expenses = snapshot.data!.docs
            .map((doc) => Expense.fromDocument(doc))
            .toList();

        return ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            Expense expense = expenses[index];

            return ListTile(
              title: Text(expense.description),
              subtitle: Text('${expense.amount}'),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('ID: ${expense.id}', style: Constants.homeTextStyle),
                ],
              ),

            );
          },
        );
      },
    );
  }
}

class NewExpenseButton extends StatelessWidget {
  final User user;

  NewExpenseButton({required this.user});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        // Add a new expense (replace this with your own logic)
        await CloudFirestore.saveExpense(user, 'New Expense', 100.0);
      },
      child: Icon(Icons.add),
    );
  }
}