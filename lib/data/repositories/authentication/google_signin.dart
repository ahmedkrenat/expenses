
import 'package:expenses/data/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:expenses/app/utils/snackbar.dart';

class GoogleSignin {
  static Future<User?> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        SnackBarHelper.failureSnackBar(context, Constants.loginWasCanceledMessage);
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
      SnackBarHelper.failureSnackBar(context, Constants.unexpectedErrorMessage);
      print('Unexpected error: $e');
    }
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();

    return null;
  }
}