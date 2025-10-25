import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';
import 'auth_state.dart';

/// Cubit for managing authentication state and operations
/// Replaces AuthViewModel with BLoC pattern
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthInitial()) {
    // Listen to auth state changes and update Cubit state
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        _loadCurrentUser();
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.signInWithEmail(email, password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('فشل تسجيل الدخول'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Register new user
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required UserType userType,
    String? workshopName,
    String? unifiedNumber,
  }) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.registerWithEmail(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        userType: userType,
        workshopName: workshopName,
        unifiedNumber: unifiedNumber,
      );

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('فشل إنشاء الحساب'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _authRepository.signOut();
    emit(const AuthUnauthenticated());
  }

  /// Load current user profile from Firestore
  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authRepository.getCurrentUserProfile();
      if (user != null) {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError('فشل تحميل بيانات المستخدم: $e'));
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    emit(const AuthLoading());

    try {
      await _authRepository.resetPassword(email);
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Clear error and return to unauthenticated state
  void clearError() {
    emit(const AuthUnauthenticated());
  }

  /// Get current user from state
  UserModel? get currentUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user;
    }
    return null;
  }
}

