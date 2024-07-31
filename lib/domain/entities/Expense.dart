import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String id;
  String description;
  double amount;
  Timestamp timestamp;
  String userId;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.timestamp,
    required this.userId,
  });

  // Factory constructor to create an Expense from a Firestore document snapshot
  factory Expense.fromDocument(DocumentSnapshot doc) {
    return Expense(
      id: doc.id,
      description: doc['description'],
      amount: doc['amount'].toDouble(),
      timestamp: doc['timestamp'],
      userId: doc['userId'],
    );
  }

  // Method to convert an Expense to a Firestore document map
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
      'timestamp': timestamp,
      'userId': userId,
    };
  }
}
