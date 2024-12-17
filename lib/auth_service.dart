import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser != null) {
        final GoogleSignInAuthentication gAuth = await gUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );

        final UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          // Check if user already exists in Firestore
          final docSnapshot = await _db.collection('users').doc(user.uid).get();
          if (!docSnapshot.exists) {
            // If the user does not exist, create a new entry
            await _db.collection('users').doc(user.uid).set({
              'uid': user.uid,
              'email': user.email,
              'displayName': user.displayName,
              'name': user.displayName?.split(' ').first,
              'surname': user.displayName?.split(' ').last,
              'phoneNumber': user.phoneNumber ?? '',
              'imageUrl': user.photoURL ?? "",
              'isPhoneVerified': false, // Add this field
            });
          }
          return user;
        }
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
    return null;
  }
}
