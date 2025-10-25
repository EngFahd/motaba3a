import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication Service
/// Handles all authentication operations (login, register, logout)
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user stream for real-time auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Create new user with email and password
  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Convert Firebase auth exceptions to user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لم يتم العثور على حساب بهذا البريد';
      case 'wrong-password':
        return 'كلمة السر غير صحيحة';
      case 'email-already-in-use':
        return 'هذا البريد مسجل بالفعل';
      case 'weak-password':
        return 'كلمة السر ضعيفة جداً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-disabled':
        return 'هذا الحساب معطل';
      case 'too-many-requests':
        return 'عدد محاولات كثيرة، حاول لاحقاً';
      default:
        return 'حدث خطأ: ${e.message}';
    }
  }
}

