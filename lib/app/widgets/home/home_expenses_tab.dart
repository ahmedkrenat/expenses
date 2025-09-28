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

class _ExpensesListViewer extends State<ExpensesListViewer> {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  void _editExpense(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => EditExpenseDialog(expense: expense),
    );
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => ExpenseDetailsDialog(expense: expense),
    );
  }

  void _deleteExpense(BuildContext context, Expense expense) async {
    await CloudFirestore.deleteExpense(expense);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${expense.description} ${Constants.deleted}"),
        action: SnackBarAction(
          label: Constants.undo,
          onPressed: () async {
            await CloudFirestore.addExpense(expense);
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
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  List<int> getAvailableYears(List<Expense> expenses) {
    final years =
        expenses.map((e) => e.timestamp.toDate().year).toSet().toList();
    years.sort((a, b) => b.compareTo(a)); // Descending
    return years;
  }

  List<int> getAvailableMonths(List<Expense> expenses, int year) {
    final months = expenses
        .where((e) => e.timestamp.toDate().year == year)
        .map((e) => e.timestamp.toDate().month)
        .toSet()
        .toList();
    months.sort();
    return months;
  }

  void _changeYear(int? year, List<Expense> expenses) {
    if (year != null) {
      setState(() {
        selectedYear = year;

        // recompute available months for this new year
        List<int> availableMonths = getAvailableMonths(expenses, selectedYear);

        // if current selectedMonth not in new year's months → fallback
        if (!availableMonths.contains(selectedMonth)) {
          selectedMonth =
              availableMonths.isNotEmpty ? availableMonths.first : 1;
        }
      });
    }
  }

  void _changeMonth(int? month) {
    if (month != null) {
      setState(() {
        selectedMonth = month;
      });
    }
  }

  double _calculateTotal(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
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

        List<int> availableYears = getAvailableYears(expenses);
        List<int> availableMonths = getAvailableMonths(expenses, selectedYear);

        // Auto-fix selectedMonth if not available
        if (!availableMonths.contains(selectedMonth)) {
          selectedMonth =
              availableMonths.isNotEmpty ? availableMonths.first : 1;
        }

        List<Expense> filteredExpenses = expenses.where((e) {
          final dt = e.timestamp.toDate();
          return dt.year == selectedYear && dt.month == selectedMonth;
        }).toList();

        double total = _calculateTotal(filteredExpenses);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Year selector
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<int>(
                      value: selectedYear,
                      decoration: const InputDecoration(
                        labelText: "Year",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (year) => _changeYear(year, expenses),
                      items: availableYears
                          .map((year) => DropdownMenuItem(
                                value: year,
                                child: Text("$year"),
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Month selector
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<int>(
                      value: selectedMonth,
                      decoration: const InputDecoration(
                        labelText: "Month",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: _changeMonth,
                      items: availableMonths
                          .map((month) => DropdownMenuItem(
                                value: month,
                                child: Text(month.toString().padLeft(2, '0')),
                              ))
                          .toList(),
                    ),
                  ),

                  const Spacer(),

                  // Total
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Total: \$${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),

                ],
              ),
            ),
            Expanded(
              child: filteredExpenses.isEmpty
                  ? Center(
                      child:
                          Text('No expenses for $selectedMonth/$selectedYear'))
                  : ListView.builder(
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = filteredExpenses[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 1.0),
                              leading: const Icon(
                                Icons.monetization_on,
                                color: Colors.green,
                              ),
                              title: Text(
                                expense.description,
                                style: Constants.itemDescTextStyle,
                              ),
                              subtitle: Text(
                                '\$${expense.amount.toStringAsFixed(2)}',
                                style: Constants.itemAmountTextStyle,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: Colors.indigo.shade400),
                                    onPressed: () =>
                                        _editExpense(context, expense),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.red.shade400),
                                    onPressed: () => _showConfirmationDialog(
                                        context, expense),
                                  ),
                                ],
                              ),
                              onTap: () =>
                                  _showExpenseDetails(context, expense),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
