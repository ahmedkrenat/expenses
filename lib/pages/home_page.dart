import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/pages/sign_in_page.dart';
import 'package:expenses/pages/utils/Expense.dart';
import 'package:expenses/pages/utils/page_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatelessWidget {
  final User user;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  HomePage({required this.user});

  Future<void> addExpense(User user, String description, double amount) async {
    final firestore = FirebaseFirestore.instance;
    Expense expense = Expense(
      id: '', // ID will be set by Firestore
      description: description,
      amount: amount,
      timestamp: Timestamp.now(),
      userId: user.uid,
    );

    await firestore.collection('expenses').add(expense.toMap());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await _googleSignIn.signOut();
              navigateToPage(context, SignInPage());
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('expenses')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No expenses found.'));
                }

                List<Expense> expenses = snapshot.data!.docs
                    .map((doc) => Expense.fromDocument(doc))
                    .toList();

                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    Expense expense = expenses[index];

                    return ListTile(
                      title: Text(expense.description),
                      subtitle: Text('${expense.amount}'),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('ID: ${expense.id}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),

                    );
                  },
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Add a new expense (replace this with your own logic)
          await addExpense(user, 'New Expense', 100.0);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
