import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/data/constants.dart';
import 'package:expenses/data/repositories/database/cloud_firestore.dart';
import 'package:expenses/domain/entities/Expense.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyExpenseStatistics extends StatefulWidget {
  final User user;

  MonthlyExpenseStatistics({required this.user});

  @override
  _MonthlyExpenseStatistics createState() => _MonthlyExpenseStatistics();
}

class _MonthlyExpenseStatistics extends State<MonthlyExpenseStatistics> {
  int _touchedIndex = -1;

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

          Map<String, double> monthlyExpenses = _calculateMonthlyExpenses(expenses);
          return _buildPieChart(monthlyExpenses);
        }
    );
  }

  Map<String, double> _calculateMonthlyExpenses(List<Expense> expenses) {
    Map<String, double> monthlyExpenses = {};

    for (var expense in expenses) {
      DateTime dateTime = expense.timestamp.toDate();
      String monthYear = DateFormat.yMMM().format(dateTime); // e.g., "Aug 2024"

      if (monthlyExpenses.containsKey(monthYear)) {
        monthlyExpenses[monthYear] = monthlyExpenses[monthYear]! + expense.amount;
      } else {
        monthlyExpenses[monthYear] = expense.amount;
      }
    }

    return monthlyExpenses;
  }

  Widget _buildPieChart(Map<String, double> monthlyExpenses) {
    List<PieChartSectionData> sections = [];
    double totalExpenses = monthlyExpenses.values.reduce((a, b) => a + b);

    // Convert entries to a list and sort them
    var sortedEntries = monthlyExpenses.entries.toList()
      ..sort((a, b) => DateFormat.yMMM().parse(a.key).compareTo(DateFormat.yMMM().parse(b.key)));

    for (int index = 0; index < sortedEntries.length; index++) {
      var entry = sortedEntries[index];
      final isTouched = index == _touchedIndex;
      final fontSize = isTouched ? 18.0 : 16.0;
      final radius = isTouched ? 120.0 : 100.0;

      sections.add(
        PieChartSectionData(
          value: entry.value,
          title: '${entry.value.toStringAsFixed(0)} ',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: _badge(entry.key.split(' ')[0]),
          badgePositionPercentageOffset: .98,
          color: _getColorForMonth(entry.key.split(' ')[0]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 60,
          sectionsSpace: 4,
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
              // setState(() {
              //   if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
              //     _touchedIndex = -1;
              //     return;
              //   }
              //   _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
              // });
            },
          ),
        ),
      ),
    );
  }

  Widget _badge(String month) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        '$month',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getColorForMonth(String month) {
    // Assign colors for different months
    switch (month) {
      case 'Jan':
        return Colors.red;
      case 'Feb':
        return Colors.blue;
      case 'Mar':
        return Colors.green;
      case 'Apr':
        return Colors.orange;
      case 'May':
        return Colors.purple;
      case 'Jun':
        return Colors.yellow;
      case 'Jul':
        return Colors.pink;
      case 'Aug':
        return Colors.teal;
      case 'Sep':
        return Colors.cyan;
      case 'Oct':
        return Colors.indigo;
      case 'Nov':
        return Colors.brown;
      case 'Dec':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
