import 'package:expenses/app/utils/page_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../home/home_page.dart';
import 'package:expenses/app/utils/snackbar.dart';


class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // User is signed in
          return HomePage(user: snapshot.data!);
        } else {
          // User is not signed in
          return SignInPage();
        }
      },
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isSigningIn = false;

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        SnackBarHelper.failureSnackBar(context, 'Login was canceled');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;

    }on PlatformException catch (e) {
      SnackBarHelper.failureSnackBar(context, '${e.message}');
      print('PlatformException: ${e.message}');
    } on FirebaseAuthException catch (e) {
      SnackBarHelper.failureSnackBar(context, '${e.message}');
      print('FirebaseAuthException: ${e.message}');
    }
    catch (e) {
      SnackBarHelper.failureSnackBar(context, 'Unexpected error, please try again');
      print('Unexpected error: $e');
    }
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display the icon
            Image.asset(
              'assets/icon/receipt.png',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 50), // Add spacing between icon and button
            Text(
              'Login', // Your text
              style: TextStyle(
                fontSize: 24, // Adjust font size as needed
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.5), // Adjust opacity (0.0 to 1.0)
              ),
            ),
            _isSigningIn
                ? CircularProgressIndicator()
                : IconButton(
                  icon: Image.asset(
                    'assets/icon/google.png', // Path to your Google sign-in icon
                    width: 30, // Adjust width as needed
                    height: 30, // Adjust height as needed
                  ),
                  onPressed: () async {
                    setState(() {
                      _isSigningIn = true;
                    });
                    User? user = await _signInWithGoogle();
                    if (user != null) {
                      SnackBarHelper.successSnackBar(context, "Login was succeed!");
                      navigateToPage(context, HomePage(user: user));
                    }else {
                      setState(() {
                        _isSigningIn = false;
                      });
                    }
                  },
            ),
          ],
        ),
      ),
    );
  }
}


