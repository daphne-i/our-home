import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/core/providers/theme_provider.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeSettings = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- 1. THEME PRESET SELECTION ---
          Text('Theme Preset', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          RadioListTile<AppThemePreset>(
            title: const Text('Ocean Breeze'),
            subtitle: const Text('Bold, modern, and energetic'),
            value: AppThemePreset.ocean,
            groupValue: themeSettings.preset,
            onChanged: (value) {
              if (value != null) {
                themeNotifier.setPreset(value);
              }
            },
          ),
          RadioListTile<AppThemePreset>(
            title: const Text('Neutral Elegance'),
            subtitle: const Text('Warm, sophisticated, and minimalist'),
            value: AppThemePreset.neutral,
            groupValue: themeSettings.preset,
            onChanged: (value) {
              if (value != null) {
                themeNotifier.setPreset(value);
              }
            },
          ),
          const Divider(height: 32),

          // --- 2. THEME MODE SELECTION ---
          Text('Theme Mode', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          RadioListTile<ThemeMode>(
            title: const Text('System'),
            secondary: const Icon(EvaIcons.smartphoneOutline),
            value: ThemeMode.system,
            groupValue: themeSettings.mode,
            onChanged: (value) {
              if (value != null) {
                themeNotifier.setMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            secondary: const Icon(EvaIcons.sunOutline),
            value: ThemeMode.light,
            groupValue: themeSettings.mode,
            onChanged: (value) {
              if (value != null) {
                themeNotifier.setMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            secondary: const Icon(EvaIcons.moonOutline),
            value: ThemeMode.dark,
            groupValue: themeSettings.mode,
            onChanged: (value) {
              if (value != null) {
                themeNotifier.setMode(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
