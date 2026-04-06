import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/bloc/theme/theme_event.dart'
    show ThemeEvent, ToggleThemeEvent, SetThemeEvent, AppThemeMode;
import 'package:spotify_clone/bloc/theme/theme_state.dart';
import 'package:spotify_clone/services/hive_service.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final HiveService _hiveService;

  static const String _themePreferenceKey = 'theme_mode';

  ThemeBloc({required HiveService hiveService})
      : _hiveService = hiveService,
        super(ThemeChanged(
          themeData: _buildDarkTheme(),
          themeMode: AppThemeMode.dark,
          isDark: true,
        )) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeEvent>(_onSetTheme);

    // Load saved theme preference on initialization
    _loadSavedTheme();
  }

  /// Handle toggling theme
  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    if (state is ThemeChanged) {
      final current = state as ThemeChanged;
      final isDark = !current.isDark;

      await _saveThemePreference(isDark);

      emit(ThemeChanged(
        themeData: isDark ? _buildDarkTheme() : _buildLightTheme(),
        themeMode: isDark ? AppThemeMode.dark : AppThemeMode.light,
        isDark: isDark,
      ));
    }
  }

  /// Handle setting specific theme
  Future<void> _onSetTheme(
    SetThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final isDark = event.themeMode == AppThemeMode.dark;

    await _saveThemePreference(isDark);

    emit(ThemeChanged(
      themeData: isDark ? _buildDarkTheme() : _buildLightTheme(),
      themeMode: event.themeMode,
      isDark: isDark,
    ));
  }

  /// Load saved theme preference from Hive
  void _loadSavedTheme() {
    try {
      final savedTheme = _hiveService.getSetting(_themePreferenceKey, 'dark');
      final isDark = savedTheme == 'dark';

      add(SetThemeEvent(isDark ? AppThemeMode.dark : AppThemeMode.light));
    } catch (e) {
      print('Error loading theme preference: $e');
    }
  }

  /// Save theme preference to Hive
  Future<void> _saveThemePreference(bool isDark) async {
    try {
      await _hiveService.saveSetting(
        _themePreferenceKey,
        isDark ? 'dark' : 'light',
      );
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  /// Build dark theme
  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF1DB954), // Spotify green
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
      ),
      cardColor: const Color(0xFF282828),
      textTheme: const TextTheme(
        displayLarge:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        displayMedium:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineSmall:
            TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        bodySmall: TextStyle(color: Colors.white60),
      ),
    );
  }

  /// Build light theme
  static ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF1DB954), // Spotify green
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
      ),
      cardColor: const Color(0xFFF5F5F5),
      textTheme: const TextTheme(
        displayLarge:
            TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        displayMedium:
            TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        headlineSmall:
            TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black87),
        bodySmall: TextStyle(color: Colors.black54),
      ),
    );
  }
}
