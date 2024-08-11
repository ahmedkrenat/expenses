import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/data/constants.dart';
import 'package:expenses/data/repositories/database/cloud_firestore.dart';
import 'package:expenses/domain/entities/Expense.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewExpenseDialog extends StatefulWidget {
  final User user;

  NewExpenseDialog({required this.user});

  @override
  _NewExpenseDialogState createState() => _NewExpenseDialogState();
}

class _NewExpenseDialogState extends State<NewExpenseDialog> {
  late TextEditingController _descController;
  late TextEditingController _amountController;
  bool _isDescEmpty = false;
  bool _isAmountEmpty = false;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: '');
    _amountController = TextEditingController(text: '');
  }

  InputDecoration _buildInputDecoration(String label, bool isEmpty) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isEmpty ? Colors.red : Colors.grey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isEmpty ? Colors.red : Colors.blue,
        ),
      ),
      suffixIcon: isEmpty
          ? Icon(
        Icons.error,
        color: Colors.red,
      )
          : null,
    );
  }

  void _handleButtonClick() async{
    setState(() {
      _isDescEmpty = _descController.text.isEmpty;
      _isAmountEmpty = _amountController.text.isEmpty;
    });

    if(_isDescEmpty || _isAmountEmpty){
      return;
    }

    Expense expense = Expense(id: '',
        description: _descController.text,
        amount: double.parse(_amountController.text),
        timestamp: Timestamp.now(),
        userId: widget.user.uid
    );

    await CloudFirestore.addExpense(expense);
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(Constants.addNewExpense),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _descController,
            decoration: _buildInputDecoration(Constants.description, _isDescEmpty),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _amountController,
            decoration: _buildInputDecoration(Constants.amount, _isAmountEmpty),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(Constants.cancel),
        ),
        ElevatedButton(
          onPressed:  _handleButtonClick,
          child: Text(Constants.save),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
