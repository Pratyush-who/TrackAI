import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static Future<void> checkAndSignOutIfNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toIso8601String().substring(
      0,
      10,
    ); // yyyy-MM-dd
    final String? lastLoginDate = prefs.getString('lastLoginDate');
    if (lastLoginDate != null && lastLoginDate != today) {
      // New day detected, sign out
      await signOut();
      await prefs.setString('lastLoginDate', today);
    } else if (lastLoginDate == null && isSignedIn) {
      // First login, set date
      await prefs.setString('lastLoginDate', today);
    }
  }

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password Sign Up
  static Future<UserCredential?> signUpWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      await _createUserDocument(userCredential.user!, displayName);

      // Store last login date
      final prefs = await SharedPreferences.getInstance();
      final String today = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.setString('lastLoginDate', today);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Email/Password Sign In
  static Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store last login date
      final prefs = await SharedPreferences.getInstance();
      final String today = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.setString('lastLoginDate', today);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Google Sign In using signInWithProvider/signInWithPopup
  static Future<UserCredential?> signInWithGoogle({
    String? linkEmail,
    String? linkPassword,
  }) async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential;
      if (Platform.isAndroid || Platform.isIOS) {
        userCredential = await _auth.signInWithProvider(googleProvider);
      } else {
        userCredential = await _auth.signInWithPopup(googleProvider);
      }
      // If linkEmail and linkPassword are provided, try to link
      if (linkEmail != null && linkPassword != null) {
        final emailCred = EmailAuthProvider.credential(
          email: linkEmail,
          password: linkPassword,
        );
        try {
          await userCredential.user?.linkWithCredential(emailCred);
        } on FirebaseAuthException catch (e) {
          if (e.code != 'provider-already-linked') {
            throw Exception(
              'Failed to link email/password: ' + (e.message ?? ''),
            );
          }
        }
      }
      // Create user document if new user
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _createUserDocument(
          userCredential.user!,
          userCredential.user?.displayName ?? 'User',
        );
      }
      return userCredential;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Reset Password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Create user document in Firestore
  static Future<void> _createUserDocument(User user, String displayName) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSignIn': FieldValue.serverTimestamp(),
        'settings': {'notifications': true, 'darkMode': true, 'language': 'en'},
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      User? user = currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);

        // Update Firestore document
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': displayName,
          'photoURL': photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  // Get user data from Firestore
  static Future<DocumentSnapshot?> getUserData() async {
    try {
      User? user = currentUser;
      if (user != null) {
        return await _firestore.collection('users').doc(user.uid).get();
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update last sign in
  static Future<void> updateLastSignIn() async {
    try {
      User? user = currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'lastSignIn': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating last sign in: $e');
    }
  }

  // Handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email address.';
      case 'user-not-found':
        return 'No user found for this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  // Check if user is signed in
  static bool get isSignedIn => currentUser != null;

  // Get user display name
  static String get userDisplayName =>
      currentUser?.displayName ?? currentUser?.email ?? 'User';

  // Get user email
  static String get userEmail => currentUser?.email ?? '';

  // Get user photo URL
  static String? get userPhotoURL => currentUser?.photoURL;
}
