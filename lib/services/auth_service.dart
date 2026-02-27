import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // clientId is intentionally omitted — the iOS OAuth client ID is read
  // automatically from GoogleService-Info.plist (CLIENT_ID key).
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _log = Logger();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign-in aborted');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      _log.i('User signed in: ${result.user?.email}');
      return result;
    } catch (e, st) {
      _log.e('Google sign-in error', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _log.i('Email sign-in: ${result.user?.email}');
      return result;
    } on FirebaseAuthException catch (e, st) {
      _log.e('Email sign-in error', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await result.user?.updateDisplayName(displayName.trim());
      _log.i('Registered: ${result.user?.email}');
      return result;
    } on FirebaseAuthException catch (e, st) {
      _log.e('Register error', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _log.i('Password reset email sent to $email');
    } on FirebaseAuthException catch (e, st) {
      _log.e('Password reset error', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    _log.i('User signed out');
  }
}
