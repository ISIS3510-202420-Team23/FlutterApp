import 'package:equatable/equatable.dart';

// Authentication States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String userEmail;

  const Authenticated({required this.userEmail});

  @override
  List<Object> get props => [userEmail];
}

// State for Google signup success
class GoogleSignupSuccess extends AuthState {
  final String userEmail;

  const GoogleSignupSuccess({required this.userEmail});

  @override
  List<Object> get props => [userEmail];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
