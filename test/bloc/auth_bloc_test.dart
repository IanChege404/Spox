import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/bloc/auth/auth_bloc.dart';
import 'package:spotify_clone/bloc/auth/auth_event.dart';
import 'package:spotify_clone/bloc/auth/auth_state.dart';
import 'package:spotify_clone/services/firebase_service.dart';

class MockFirebaseService extends Mock implements FirebaseService {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  group('AuthBloc', () {
    late MockFirebaseService mockFirebaseService;
    late AuthBloc authBloc;

    final mockUser = MockUser();
    final mockUserCredential = MockUserCredential();

    setUp(() {
      mockFirebaseService = MockFirebaseService();

      // Mock auth state changes stream
      when(() => mockFirebaseService.authStateChanges)
          .thenAnswer((_) => Stream<User?>.empty());

      authBloc = AuthBloc(firebaseService: mockFirebaseService);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    // Happy path: Google Sign-In Success
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when SignInWithGoogleEvent succeeds',
      build: () => authBloc,
      act: (bloc) {
        when(() => mockFirebaseService.signInWithGoogle())
            .thenAnswer((_) async {
          when(() => mockUserCredential.user).thenReturn(mockUser);
          when(() => mockUser.uid).thenReturn('google-user-123');
          when(() => mockUser.email).thenReturn('user@gmail.com');
          when(() => mockUser.displayName).thenReturn('Test User');
          return mockUserCredential;
        });

        bloc.add(const SignInWithGoogleEvent());
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    // Error scenario: Google Sign-In Cancelled
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when Google sign-in is cancelled',
      build: () => authBloc,
      act: (bloc) {
        when(() => mockFirebaseService.signInWithGoogle())
            .thenAnswer((_) async => null);

        bloc.add(const SignInWithGoogleEvent());
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>()
            .having((state) => state.message, 'message', contains('cancelled')),
      ],
    );

    // Error scenario: Google Sign-In Exception
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when Google sign-in throws exception',
      build: () => authBloc,
      act: (bloc) {
        when(() => mockFirebaseService.signInWithGoogle())
            .thenThrow(Exception('Network error'));

        bloc.add(const SignInWithGoogleEvent());
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((state) => state.message, 'message',
            contains('Failed to sign in with Google')),
      ],
    );

    // Happy path: Email Sign-In Success
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when SignInWithEmailEvent succeeds',
      build: () => authBloc,
      act: (bloc) {
        when(() => mockFirebaseService.signInWithEmailPassword(
              'test@example.com',
              'password123',
            )).thenAnswer((_) async {
          when(() => mockUserCredential.user).thenReturn(mockUser);
          when(() => mockUser.uid).thenReturn('email-user-123');
          when(() => mockUser.email).thenReturn('test@example.com');
          return mockUserCredential;
        });

        bloc.add(const SignInWithEmailEvent(
          email: 'test@example.com',
          password: 'password123',
        ));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    // Error scenario: Invalid Email/Password
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when email sign-in fails with invalid credentials',
      build: () => authBloc,
      act: (bloc) {
        when(() => mockFirebaseService.signInWithEmailPassword(
              'wrong@example.com',
              'wrongpassword',
            )).thenThrow(Exception('Invalid email or password'));

        bloc.add(const SignInWithEmailEvent(
          email: 'wrong@example.com',
          password: 'wrongpassword',
        ));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having(
            (state) => state.message, 'message', contains('Failed to sign in')),
      ],
    );

    // Happy path: Registration Success
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when RegisterEvent succeeds',
      build: () => authBloc,
      act: (bloc) {
        when(() => mockFirebaseService.registerWithEmailPassword(
              'newuser@example.com',
              'password123',
              'New User',
            )).thenAnswer((_) async {
          when(() => mockUserCredential.user).thenReturn(mockUser);
          when(() => mockUser.uid).thenReturn('new-user-123');
          when(() => mockUser.email).thenReturn('newuser@example.com');
          when(() => mockUser.displayName).thenReturn('New User');
          return mockUserCredential;
        });

        bloc.add(const RegisterEvent(
          email: 'newuser@example.com',
          password: 'password123',
          displayName: 'New User',
        ));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>(),
      ],
    );

    // Error scenario: Registration Failed (duplicate email)
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when registration fails with duplicate email',
      build: () => authBloc,
      act: (bloc) {
        when(() => mockFirebaseService.registerWithEmailPassword(
              'existing@example.com',
              'password123',
              'Existing User',
            )).thenThrow(Exception('Email already in use'));

        bloc.add(const RegisterEvent(
          email: 'existing@example.com',
          password: 'password123',
          displayName: 'Existing User',
        ));
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((state) => state.message, 'message',
            contains('Failed to register')),
      ],
    );

    // Happy path: Sign Out Success
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSignedOut, AuthUnauthenticated] when SignOutEvent is added',
      build: () => authBloc,
      act: (bloc) {
        when(() => mockFirebaseService.signOut())
            .thenAnswer((_) async => Future.value());

        bloc.add(const SignOutEvent());
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthSignedOut>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    // Error scenario: Sign Out Failed
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when sign out fails',
      build: () => authBloc,
      act: (bloc) {
        when(() => mockFirebaseService.signOut())
            .thenThrow(Exception('Sign out failed'));

        bloc.add(const SignOutEvent());
      },
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((state) => state.message, 'message',
            contains('Failed to sign out')),
      ],
    );

    // Verify method calls
    blocTest<AuthBloc, AuthState>(
      'calls signInWithEmail with correct parameters',
      build: () => authBloc,
      act: (bloc) {
        when(() => mockFirebaseService.signInWithEmailPassword(
              'test@example.com',
              'password123',
            )).thenAnswer((_) async {
          when(() => mockUserCredential.user).thenReturn(mockUser);
          return mockUserCredential;
        });

        bloc.add(const SignInWithEmailEvent(
          email: 'test@example.com',
          password: 'password123',
        ));
      },
      verify: (bloc) {
        verify(() => mockFirebaseService.signInWithEmailPassword(
              'test@example.com',
              'password123',
            )).called(1);
      },
    );
  });
}
