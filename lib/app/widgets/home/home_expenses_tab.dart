import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/app/widgets/home/expense_details_dialog.dart';
import 'package:expenses/data/constants.dart';
import 'package:expenses/data/repositories/database/cloud_firestore.dart';
import 'package:expenses/domain/entities/Expense.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'confirmation_dialog.dart';
import 'edit_expense_dialog.dart';

class ExpensesListViewer extends StatefulWidget {
  final User user;

  ExpensesListViewer({required this.user});

  @override
  _ExpensesListViewer createState() => _ExpensesListViewer();
}

class _ExpensesListViewer extends State<ExpensesListViewer>{
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  void _editExpense(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) {
        return EditExpenseDialog(expense: expense);
      },
    );
  }

  void _showExpenseDetails(BuildContext context, Expense expense){
    showDialog(
      context: context,
      builder: (context) {
        return ExpenseDetailsDialog(expense: expense);
      },
    );
  }

  void _deleteExpense(BuildContext context, Expense expense) {
    setState(() {
      CloudFirestore.deleteExpense(expense);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${expense.description} ${Constants.deleted}"),
        action: SnackBarAction(
          label: Constants.undo,
          onPressed: () {
            setState(() async {
              await CloudFirestore.addExpense(expense);
            });
          },
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'Confirm Action',
          content: 'Are you sure you want to delete this expense?',
          actionText: 'Delete',
          onConfirm: () {
            Navigator.of(context).pop();
            _deleteExpense(context, expense);
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: CloudFirestore.getExpensesStream(widget.user),
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

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
                  leading: Icon(
                    Icons.monetization_on,
                    color: Colors.green,
                  ),
                  title: Text(
                    expense.description,
                    style: Constants.itemDescTextStyle,
                  ),
                  subtitle: Text(
                    '\$${expense.amount.toStringAsFixed(1)}',
                    style: Constants.itemAmountTextStyle,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.indigo.shade400,
                        ),
                        onPressed: () => _editExpense(context, expense),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red.shade400,
                        ),
                        onPressed: () => _showConfirmationDialog(context, expense),
                      ),
                    ],
                  ),
                  onTap: () => _showExpenseDetails(context, expense),
                ),
              ),
            );
          },
        );
        },
    );
  }
}