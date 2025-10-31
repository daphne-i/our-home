import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Define the enums for our settings
enum AppThemePreset {
  ocean,
  neutral,
}

// 2. Define the State class for our Notifier
// This holds the user's current theme settings
class ThemeSettings {
  final AppThemePreset preset;
  final ThemeMode mode;

  ThemeSettings({
    required this.preset,
    required this.mode,
  });

  // Helper method to copy the state
  ThemeSettings copyWith({
    AppThemePreset? preset,
    ThemeMode? mode,
  }) {
    return ThemeSettings(
      preset: preset ?? this.preset,
      mode: mode ?? this.mode,
    );
  }
}

// 3. Create the Notifier
// This class will manage the state and save/load it from SharedPreferences
class ThemeNotifier extends StateNotifier<ThemeSettings> {
  late SharedPreferences _prefs;

  ThemeNotifier()
      : super(ThemeSettings(
          preset: AppThemePreset.ocean, // Default theme
          mode: ThemeMode.system, // Default mode
        )) {
    // We can't load prefs synchronously, so we start with defaults
    // and kick off an async method to load the user's saved prefs.
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    // Load saved settings
    final themeName = _prefs.getString('theme_preset');
    final themeModeName = _prefs.getString('theme_mode');

    // Update the state with loaded values, if they exist
    state = ThemeSettings(
      preset: themeName == 'neutral'
          ? AppThemePreset.neutral
          : AppThemePreset.ocean,
      mode: themeModeName == 'light'
          ? ThemeMode.light
          : themeModeName == 'dark'
              ? ThemeMode.dark
              : ThemeMode.system,
    );
  }

  // Public methods to allow the UI to change the theme
  void setPreset(AppThemePreset preset) {
    _prefs.setString('theme_preset', preset.name);
    state = state.copyWith(preset: preset);
  }

  void setMode(ThemeMode mode) {
    _prefs.setString('theme_mode', mode.name);
    state = state.copyWith(mode: mode);
  }
}

// 4. Create the provider
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeSettings>((ref) {
  return ThemeNotifier();
});
