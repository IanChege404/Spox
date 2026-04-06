import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:spotify_clone/bloc/theme/theme_event.dart' show AppThemeMode;

abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

/// State representing the current theme
class ThemeChanged extends ThemeState {
  final ThemeData themeData;
  final AppThemeMode themeMode;
  final bool isDark;

  const ThemeChanged({
    required this.themeData,
    required this.themeMode,
    required this.isDark,
  });

  @override
  List<Object?> get props => [themeData, themeMode, isDark];

  /// Copy with modified theme
  ThemeChanged copyWith({
    ThemeData? themeData,
    AppThemeMode? themeMode,
    bool? isDark,
  }) {
    return ThemeChanged(
      themeData: themeData ?? this.themeData,
      themeMode: themeMode ?? this.themeMode,
      isDark: isDark ?? this.isDark,
    );
  }
}
