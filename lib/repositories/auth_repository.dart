import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Repository handling all authentication operations
/// Encapsulates Firebase Auth and user profile creation
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream for real-time auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Sign in with email and password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return await _getUserProfile(credential.user!.uid);
      }
      return null;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in with phone number (requires phone verification flow)
  /// This is a placeholder - implement SMS verification in production
  Future<UserModel?> signInWithPhone(String phoneNumber, String code) async {
    // TODO: Implement phone auth with Firebase SMS verification
    throw UnimplementedError('Phone auth requires SMS verification setup');
  }

  /// Register new user with email and password
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required UserType userType,
    String? workshopName,
    String? unifiedNumber,
  }) async {
    try {
      // Create Firebase auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user profile in Firestore
        final userModel = UserModel(
          uid: credential.user!.uid,
          name: name,
          phoneNumber: phoneNumber,
          email: email,
          userType: userType,
          workshopName: workshopName,
          unifiedNumber: unifiedNumber,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toMap());

        return userModel;
      }
      return null;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Get user profile from Firestore
  Future<UserModel?> _getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

  /// Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    final uid = currentUserId;
    if (uid != null) {
      return await _getUserProfile(uid);
    }
    return null;
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Convert Firebase auth exceptions to user-friendly messages
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
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
        default:
          return 'حدث خطأ: ${e.message}';
      }
    }
    return 'حدث خطأ غير متوقع';
  }
}

