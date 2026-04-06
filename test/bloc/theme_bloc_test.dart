import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spotify_clone/bloc/theme/theme_bloc.dart';
import 'package:spotify_clone/bloc/theme/theme_event.dart';
import 'package:spotify_clone/bloc/theme/theme_state.dart';
import 'package:spotify_clone/services/hive_service.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  group('ThemeBloc', () {
    late MockHiveService mockHiveService;
    late ThemeBloc themeBloc;

    setUp(() {
      mockHiveService = MockHiveService();

      // Mock Hive service methods
      when(() => mockHiveService.getSetting(any(), any())).thenReturn(null);
      when(() => mockHiveService.saveSetting(any(), any()))
          .thenAnswer((_) async => Future.value());

      themeBloc = ThemeBloc(hiveService: mockHiveService);
    });

    tearDown(() {
      themeBloc.close();
    });

    test('initial state is dark theme', () {
      final state = themeBloc.state;
      expect(state, isA<ThemeChanged>());
      if (state is ThemeChanged) {
        expect(state.isDark, isTrue);
        expect(state.themeMode, AppThemeMode.dark);
      }
    });

    // Toggle from dark to light
    blocTest<ThemeBloc, ThemeState>(
      'emits ThemeChanged with light theme when toggling from dark',
      build: () => themeBloc,
      seed: () => ThemeChanged(
        themeData: _buildDarkTheme(),
        themeMode: AppThemeMode.dark,
        isDark: true,
      ),
      act: (bloc) {
        when(() => mockHiveService.saveSetting(any(), any()))
            .thenAnswer((_) async => Future.value());

        bloc.add(const ToggleThemeEvent());
      },
      expect: () => [
        isA<ThemeChanged>()
            .having((state) => state.isDark, 'isDark', false)
            .having(
                (state) => state.themeMode, 'themeMode', AppThemeMode.light),
      ],
    );

    // Toggle from light to dark
    blocTest<ThemeBloc, ThemeState>(
      'emits ThemeChanged with dark theme when toggling from light',
      build: () => themeBloc,
      seed: () => ThemeChanged(
        themeData: _buildLightTheme(),
        themeMode: AppThemeMode.light,
        isDark: false,
      ),
      act: (bloc) {
        when(() => mockHiveService.saveSetting(any(), any()))
            .thenAnswer((_) async => Future.value());

        bloc.add(const ToggleThemeEvent());
      },
      expect: () => [
        isA<ThemeChanged>()
            .having((state) => state.isDark, 'isDark', true)
            .having((state) => state.themeMode, 'themeMode', AppThemeMode.dark),
      ],
    );

    // Set specific theme to dark
    blocTest<ThemeBloc, ThemeState>(
      'emits ThemeChanged when SetThemeEvent is added with dark mode',
      build: () => themeBloc,
      act: (bloc) {
        when(() => mockHiveService.saveSetting(any(), any()))
            .thenAnswer((_) async => Future.value());

        bloc.add(const SetThemeEvent(AppThemeMode.dark));
      },
      expect: () => [
        isA<ThemeChanged>()
            .having((state) => state.isDark, 'isDark', true)
            .having((state) => state.themeMode, 'themeMode', AppThemeMode.dark),
      ],
    );

    // Set specific theme to light
    blocTest<ThemeBloc, ThemeState>(
      'emits ThemeChanged when SetThemeEvent is added with light mode',
      build: () => themeBloc,
      seed: () => ThemeChanged(
        themeData: _buildDarkTheme(),
        themeMode: AppThemeMode.dark,
        isDark: true,
      ),
      act: (bloc) {
        when(() => mockHiveService.saveSetting(any(), any()))
            .thenAnswer((_) async => Future.value());

        bloc.add(const SetThemeEvent(AppThemeMode.light));
      },
      expect: () => [
        isA<ThemeChanged>()
            .having((state) => state.isDark, 'isDark', false)
            .having(
                (state) => state.themeMode, 'themeMode', AppThemeMode.light),
      ],
    );

    // Verify theme persistence
    blocTest<ThemeBloc, ThemeState>(
      'saves theme preference to Hive when theme is toggled',
      build: () => themeBloc,
      act: (bloc) {
        // Reset mock to clear any calls from bloc construction
        reset(mockHiveService);
        when(() => mockHiveService.saveSetting(any(), any()))
            .thenAnswer((_) async => Future.value());

        bloc.add(const ToggleThemeEvent());
      },
      verify: (bloc) {
        verify(() => mockHiveService.saveSetting(any(), any())).called(1);
      },
    );

    // Edge case: Rapid toggle
    blocTest<ThemeBloc, ThemeState>(
      'handles rapid theme toggles correctly',
      build: () => themeBloc,
      seed: () => ThemeChanged(
        themeData: _buildDarkTheme(),
        themeMode: AppThemeMode.dark,
        isDark: true,
      ),
      act: (bloc) {
        when(() => mockHiveService.saveSetting(any(), any()))
            .thenAnswer((_) async => Future.value());

        bloc.add(const ToggleThemeEvent());
        bloc.add(const ToggleThemeEvent());
        bloc.add(const ToggleThemeEvent());
      },
      expect: () => [
        isA<ThemeChanged>().having((state) => state.isDark, 'isDark', false),
        isA<ThemeChanged>().having((state) => state.isDark, 'isDark', true),
        isA<ThemeChanged>().having((state) => state.isDark, 'isDark', false),
      ],
    );
  });
}

// Mock theme builders (these should match implementation)
ThemeData _buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1DB954),
  );
}

ThemeData _buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1DB954),
  );
}
