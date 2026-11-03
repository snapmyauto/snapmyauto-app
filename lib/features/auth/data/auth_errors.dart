import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(Object error) {
  if (error is! FirebaseAuthException) {
    return 'Something went wrong. Please try again.';
  }
  switch (error.code) {
    case 'invalid-email':
      return 'That email address doesn\'t look right.';
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'Email or password is incorrect.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'email-already-in-use':
      return 'An account with this email already exists.';
    case 'weak-password':
      return 'Password is too weak. Use at least 8 characters.';
    case 'too-many-requests':
      return 'Too many attempts. Wait a minute and try again.';
    case 'network-request-failed':
      return 'No internet connection.';
    default:
      return 'Something went wrong. Please try again.';
  }
}
