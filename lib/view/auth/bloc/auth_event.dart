import 'package:equatable/equatable.dart';

// Authentication Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// Email/Password Login Event
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

// Google Login Event
class GoogleLoginRequested extends AuthEvent {
  const GoogleLoginRequested();

  @override
  List<Object> get props => [];
}


// Google Signup Event
class GoogleSignupRequested extends AuthEvent {
  const GoogleSignupRequested();

  @override
  List<Object> get props => [];
}

// Logout Event
class LogoutRequested extends AuthEvent {}
