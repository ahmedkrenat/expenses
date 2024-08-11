import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/data/constants.dart';
import 'package:expenses/domain/entities/Expense.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudFirestore {

  static Future<void> deleteExpense(Expense expense) async {
    final firestore = FirebaseFirestore.instance;
    await firestore
        .collection(Constants.expensesCollectionName)
        .doc(expense.id)
        .delete();
  }

  static Future<void> updateExpense(Expense expense) async {
    final firestore = FirebaseFirestore.instance;
    await firestore
        .collection(Constants.expensesCollectionName)
        .doc(expense.id)
        .set(expense.toMap());
  }

  static Future<void> addExpense(Expense expense) async {
    final firestore = FirebaseFirestore.instance;

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