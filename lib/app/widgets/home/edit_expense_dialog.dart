import 'package:expenses/data/constants.dart';
import 'package:expenses/data/repositories/database/cloud_firestore.dart';
import 'package:expenses/domain/entities/Expense.dart';
import 'package:flutter/material.dart';

class EditExpenseDialog extends StatefulWidget {
  final Expense expense;

  EditExpenseDialog({required this.expense});

  @override
  _EditExpenseDialogState createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends State<EditExpenseDialog> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.description);
    _amountController = TextEditingController(text: widget.expense.amount.toStringAsFixed(1));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(Constants.editExpense),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: Constants.description),
          ),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(labelText: Constants.amount),
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
          onPressed: () async {
            await CloudFirestore.updateExpense(widget.expense);
            setState(() {
              widget.expense.description = _titleController.text;
              widget.expense.amount = double.parse(_amountController.text);
            });
            await CloudFirestore.updateExpense(widget.expense);
            Navigator.of(context).pop();
          },
          child: Text(Constants.save),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
