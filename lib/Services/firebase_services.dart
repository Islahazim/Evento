import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _firestore = FirebaseFirestore.instance;

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
      await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleAuth =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        // Save user data to Firestore
        if (user != null) {
          await _saveUserData(user);
        }

        return user;
      }
    } on FirebaseAuthException catch (e) {
      print("Error during Google Sign-In: ${e.message}");
      rethrow;
    }
    return null;
  }

  // Save user data to Firestore
  Future<void> _saveUserData(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      // Only save if the user doesn't already exist
      if (!docSnapshot.exists) {
        await userDoc.set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          'createdAt': DateTime.now().toIso8601String(),
        });
        print("User data saved to Firestore.");
      } else {
        print("User data already exists in Firestore.");
      }
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  // Sign out from Google and Firebase
  Future<void> googleSignOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      print("User signed out successfully.");
    } catch (e) {
      print("Error during sign out: $e");
    }
  }
}
