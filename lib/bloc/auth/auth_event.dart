import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to sign in with Google
class SignInWithGoogleEvent extends AuthEvent {
  const SignInWithGoogleEvent();
}

/// Event to sign in with email and password
class SignInWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event to register with email and password
class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const RegisterEvent({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Event to sign out
class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

/// Event to check authentication status
class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}
