import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String username;
  final String? fullName;

  AuthAuthenticated(this.username, {this.fullName});

  @override
  List<Object?> get props => [username, fullName];
}

// ✅ حالة جديدة: المستخدم اختار الدخول كضيف
class AuthGuest extends AuthState {}

class AuthProfileIncomplete extends AuthState {
  final String userId;
  final String email;

  AuthProfileIncomplete({required this.userId, required this.email});

  @override
  List<Object?> get props => [userId, email];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
