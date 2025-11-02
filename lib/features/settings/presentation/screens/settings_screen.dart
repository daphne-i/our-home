import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:homely/features/auth/application/auth_service.dart';
import 'package:homely/core/providers/theme_provider.dart'; // From your main.dart
import 'package:homely/core/app_theme.dart'; // From your main.dart

// TODO: Import Profile, Household, and Theme screens
// import 'package:homely/features/settings/presentation/screens/household_settings_screen.dart'; [cite: 100-101]
// import 'package:homely/features/settings/presentation/screens/theme_settings_screen.dart'; [cite: 102-103]

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // This data should come from your theme provider
    final themeSettings =
        ref.watch(themeNotifierProvider); // From your main.dart
    final themeName =
        themeSettings.preset == AppThemePreset.ocean ? "Ocean" : "Neutral";
    final themeMode = themeSettings.mode.name;
    final themeDescription =
        "$themeName - ${themeMode[0].toUpperCase()}${themeMode.substring(1)} Mode";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            themeDescription, // Dynamically loaded
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(EvaIcons.personOutline),
            title: const Text('Profile'),
            trailing: const Icon(EvaIcons.arrowIosForwardOutline),
            onTap: () {
              // TODO: Navigate to Profile Screen
            },
          ),
          ListTile(
            leading: const Icon(EvaIcons.homeOutline),
            title: const Text('Household'),
            trailing: const Icon(EvaIcons.arrowIosForwardOutline),
            onTap: () {
              // TODO: Navigate to Household Settings Screen [cite: 100]
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const HouseholdSettingsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(EvaIcons.colorPaletteOutline),
            title: const Text('Theme'),
            trailing: const Icon(EvaIcons.arrowIosForwardOutline),
            onTap: () {
              // TODO: Navigate to Theme Settings Screen [cite: 102]
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const ThemeSettingsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(EvaIcons.options2Outline),
            title: const Text('Manage Categories'),
            trailing: const Icon(EvaIcons.arrowIosForwardOutline),
            onTap: () {
              // TODO: Navigate to Manage Categories Screen
            },
          ),
          const Divider(),
          ListTile(
            leading:
                Icon(EvaIcons.logOutOutline, color: theme.colorScheme.error),
            title: Text('Log Out',
                style: TextStyle(color: theme.colorScheme.error)),
            onTap: () async {
              // Use the AuthService to sign out
              await ref.read(authServiceProvider).signOut();
              // AuthGate will automatically handle navigation back to WelcomeScreen
            },
          ),
        ],
      ),
    );
  }
}
