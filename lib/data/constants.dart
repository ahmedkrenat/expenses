import 'package:flutter/material.dart';

class Constants {
  static const String homeText = "Home";
  static const String signInText = "Sign in";
  static const String signedInSuccessfully = "Login was succeed!";
  static const String expensesCollectionName = 'expenses';
  static const String userIdColumn = 'userId';
  static const String timestampColumn = 'timestamp';
  static const String noExpensesFound = 'No expenses found';
  static const TextStyle homeTextStyle = TextStyle(fontSize: 12, color: Colors.grey);
  static const TextStyle itemDescTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  static final TextStyle itemAmountTextStyle = TextStyle( color: Colors.grey[600], fontSize: 14);
  static const String signInIconPath = 'assets/icon/receipt.png';
  static const TextStyle signInTextStyle = TextStyle(fontSize: 20, color: Colors.grey);
  static const String signInButtonIconPath = 'assets/icon/google.png';
  static const String loginWasCanceledMessage =  'Login was canceled';
  static const String unexpectedErrorMessage = 'Unexpected error, please try again';
  static const String deleted = 'deleted';
  static const String undo = 'Undo';
  static const String editExpense = 'Edit Expense';
  static const String expenseDetails = 'Expense details';
  static const String description = 'Description';
  static const String amount = 'Amount';
  static const String date = 'Date';
  static const String category = 'Category';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String addNewExpense = 'Add new expense';



}