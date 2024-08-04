import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/data/constants.dart';
import 'package:expenses/domain/entities/Expense.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudFirestore {

  static Future<void> saveExpense(User user, String description, double amount) async {
    final firestore = FirebaseFirestore.instance;
    Expense expense = Expense(
      id: '', // ID will be set by Firestore
      description: description,
      amount: amount,
      timestamp: Timestamp.now(),
      userId: user.uid,
    );

    await firestore.collection(Constants.expensesCollectionName).add(expense.toMap());
  }

  static Stream<QuerySnapshot<Object?>>? getExpensesStream(User user){
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;

    return fireStore
        .collection(Constants.expensesCollectionName)
        .where(Constants.userIdColumn, isEqualTo: user.uid)
        .orderBy(Constants.timestampColumn, descending: true)
        .snapshots();
  }
}