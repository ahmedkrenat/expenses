import 'package:expenses/app/utils/utils.dart';
import 'package:expenses/data/constants.dart';
import 'package:expenses/domain/entities/Expense.dart';
import 'package:flutter/material.dart';

class ExpenseDetailsDialog extends StatelessWidget {
  final Expense expense;

  ExpenseDetailsDialog({required this.expense});

  Widget _buildDetailRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        Constants.expenseDetails,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.indigo,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            label: Constants.description,
            value: expense.description,
          ),
          SizedBox(height: 12),
          _buildDetailRow(
            label: Constants.amount,
            value: '\$${expense.amount.toStringAsFixed(2)}',
          ),
          SizedBox(height: 12),
          _buildDetailRow(
            label: Constants.date,
            value: formatTimestamp(expense.timestamp),
          ),
          // SizedBox(height: 12),
          // _buildDetailRow(
          //   label: Constants.category,
          //   value: expense.category,
          // ),
        ],
      ),
    );
  }
}
