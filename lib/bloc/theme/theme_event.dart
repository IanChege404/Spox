import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to toggle between dark and light theme
class ToggleThemeEvent extends ThemeEvent {
  const ToggleThemeEvent();
}

/// Event to set specific theme
class SetThemeEvent extends ThemeEvent {
  final AppThemeMode themeMode;

  const SetThemeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

enum AppThemeMode { light, dark, system }
