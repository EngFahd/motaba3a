import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

/// Base class for all authentication states
/// Uses Equatable for easy state comparison in BLoC
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when app starts
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during authentication operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state with user data
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state (logged out)
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state with error message
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

