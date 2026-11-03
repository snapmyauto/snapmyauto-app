import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/app_config.dart';

class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;
  bool _googleReady = false;

  Stream<User?> authChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<User?> register(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user?.updateDisplayName(name.trim());
    return cred.user;
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> _initGoogle() async {
    if (_googleReady) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleWebClientId,
    );
    _googleReady = true;
  }

  Future<void> signInWithGoogle() async {
    await _initGoogle();
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(code: 'missing-id-token');
    }
    await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
  }

  Future<void> signOut() async {
    // clear google too, so the account picker shows next time
    if (_googleReady) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
    await _auth.signOut();
  }
}

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(firebaseAuthProvider)),
);

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authChanges(),
);
