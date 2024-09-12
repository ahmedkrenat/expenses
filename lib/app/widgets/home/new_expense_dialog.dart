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
  late TextEditingController _installmentsController;
  final TextEditingController _dateTimeController = TextEditingController();
  bool _isDescEmpty = false;
  bool _isAmountEmpty = false;
  bool _isInstallmentsEmpty = false;
  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: '');
    _amountController = TextEditingController(text: '');
    _installmentsController = TextEditingController(text: '1');
    _dateTimeController.text = _selectedDateTime.toLocal().toString().split('.')[0];
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

  List<Timestamp> _getFirstOfNextXMonths(Timestamp timestamp, int x) {
    DateTime dateTime = timestamp.toDate();
    List<Timestamp> result = [];
    result.add(timestamp);

    for (int i = 1; i < x; i++) {
      int year = dateTime.year;
      int month = dateTime.month + i;

      if (month > 12) {
        year += (month - 1) ~/ 12;
        month = month % 12 == 0 ? 12 : month % 12;
      }

      DateTime firstDayOfMonth = DateTime(year, month, 1);

      result.add(Timestamp.fromDate(firstDayOfMonth));
    }

    return result;
  }

  void _handleButtonClick() async{
    setState(() {
      _isDescEmpty = _descController.text.isEmpty;
      _isAmountEmpty = _amountController.text.isEmpty || int.parse((_amountController.text)) == 0;
      _isInstallmentsEmpty = _installmentsController.text.isEmpty || int.parse((_installmentsController.text)) == 0;
    });

    if(_isDescEmpty || _isAmountEmpty){
      return;
    }

    Expense expense;
    Timestamp timestamp = Timestamp.fromDate(_selectedDateTime);;
    int installments = int.parse((_installmentsController.text));
    var amount = double.parse(_amountController.text) / installments;
    List<Timestamp> timeStamps = _getFirstOfNextXMonths(timestamp, installments);

    for(int i=0; i<installments; i++){
      expense = Expense(id: '',
            description: _descController.text,
            amount: amount,
            timestamp: timeStamps[i],
            userId: widget.user.uid
        );

      await CloudFirestore.addExpense(expense);
    }


    Navigator.of(context).pop();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateTimeController.text = _selectedDateTime.toLocal().toString().split('.')[0];
        });
      }
    }
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
          SizedBox(height: 10),
          TextField(
            controller: _dateTimeController,
            decoration: InputDecoration(
              labelText: 'Date & Time',
              suffixIcon: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDateTime(context),
              ),
            ),
            readOnly: true,
          ),
          SizedBox(height: 10),
          TextField(
            controller: _installmentsController,
            decoration: _buildInputDecoration(Constants.installments, _isInstallmentsEmpty),
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
