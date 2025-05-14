// services/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _user != null;

  AuthProvider() {
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    // Check if user is signed in with Firebase
    _user = _auth.currentUser;

    // If user is not signed in, check shared preferences for any stored auth state
    if (_user == null) {
      final prefs = await SharedPreferences.getInstance();
      final hasLoggedInBefore = prefs.getBool('hasLoggedInBefore') ?? false;

      if (hasLoggedInBefore) {
        try {
          // Attempt to sign in silently if user has logged in before
          final googleUser = await _googleSignIn.signInSilently();
          if (googleUser != null) {
            await _authenticateWithGoogle(googleUser);
          }
        } catch (e) {
          print('Error signing in silently: $e');
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Trigger the Google Sign-In flow
      final googleUser = await _googleSignIn.signIn();

      // User canceled the sign-in
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Authenticate with Firebase
      await _authenticateWithGoogle(googleUser);

      // Save authentication state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasLoggedInBefore', true);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Sign-in error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _authenticateWithGoogle(GoogleSignInAccount googleUser) async {
    // Get authentication details from Google
    final googleAuth = await googleUser.authentication;

    // Create credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase
    final userCredential = await _auth.signInWithCredential(credential);
    _user = userCredential.user;
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _googleSignIn.signOut();
    await _auth.signOut();

    // Clear persistent auth state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasLoggedInBefore', false);

    _user = null;
    _isLoading = false;
    notifyListeners();
  }
}
