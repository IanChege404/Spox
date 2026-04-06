import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:spotify_clone/bloc/auth/auth_event.dart';
import 'package:spotify_clone/bloc/auth/auth_state.dart';
import 'package:spotify_clone/services/firebase_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseService _firebaseService;
  late StreamSubscription<dynamic> _authStateSubscription;

  AuthBloc({required FirebaseService firebaseService})
      : _firebaseService = firebaseService,
        super(const AuthInitial()) {
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<RegisterEvent>(_onRegister);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<_AuthStateChanged>(_onAuthStateChanged);

    _setupAuthStateListener();
  }

  /// Listen to Firebase auth state changes
  void _setupAuthStateListener() {
    _authStateSubscription =
        _firebaseService.authStateChanges.listen((user) {
      add(_AuthStateChanged(user));
    });
  }

  /// Handle auth state changes from Firebase
  Future<void> _onAuthStateChanged(
    _AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle sign in with Google
  FutureOr<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final userCredential = await _firebaseService.signInWithGoogle();

      if (userCredential != null) {
        emit(AuthAuthenticated(userCredential.user!));
      } else {
        emit(const AuthError('Google sign-in was cancelled'));
      }
    } catch (e) {
      emit(AuthError('Failed to sign in with Google: ${e.toString()}'));
    }
  }

  /// Handle sign in with email and password
  FutureOr<void> _onSignInWithEmail(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final userCredential = await _firebaseService.signInWithEmailPassword(
        event.email,
        event.password,
      );

      emit(AuthAuthenticated(userCredential.user!));
    } catch (e) {
      emit(AuthError('Failed to sign in: ${e.toString()}'));
    }
  }

  /// Handle registration
  FutureOr<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final userCredential =
          await _firebaseService.registerWithEmailPassword(
        event.email,
        event.password,
        event.displayName,
      );

      emit(AuthAuthenticated(userCredential.user!));
    } catch (e) {
      emit(AuthError('Failed to register: ${e.toString()}'));
    }
  }

  /// Handle sign out
  FutureOr<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      await _firebaseService.signOut();

      emit(const AuthSignedOut());
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to sign out: ${e.toString()}'));
    }
  }

  /// Handle checking auth status
  FutureOr<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) {
    final user = _firebaseService.currentUser;

    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() async {
    await _authStateSubscription.cancel();
    return super.close();
  }
}

/// Internal event to handle Firebase auth state changes
class _AuthStateChanged extends AuthEvent {
  final dynamic user;

  const _AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}
