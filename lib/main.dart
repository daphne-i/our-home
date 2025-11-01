import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/features/auth/presentation/auth_gate.dart';

// --- Import Firebase options ---
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Make sure you have generated this file

// Import our new theme files
import 'package:homely/core/app_theme.dart';
import 'package:homely/core/providers/theme_provider.dart';

void main() async {
  // Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // --- Initialize Firebase ---
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app, wrapped in Riverpod's ProviderScope
  runApp(
    const ProviderScope(
      child: HomelyApp(),
    ),
  );
}

class HomelyApp extends ConsumerWidget {
  const HomelyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme provider to get the user's current settings
    final themeSettings = ref.watch(themeNotifierProvider);

    // Logic to select the correct ThemeData based on user's choice
    late final ThemeData lightTheme;
    late final ThemeData darkTheme;

    switch (themeSettings.preset) {
      case AppThemePreset.ocean:
        lightTheme = AppTheme.oceanLightTheme;
        darkTheme = AppTheme.oceanDarkTheme;
        break;
      case AppThemePreset.neutral:
        lightTheme = AppTheme.neutralLightTheme;
        darkTheme = AppTheme.neutralDarkTheme;
        break;
    }

    return MaterialApp(
      title: 'Homely',
      debugShowCheckedModeBanner: false,

      // --- Theme Setup (from our provider) ---
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeSettings.mode,

      // AuthGate will now handle showing WelcomeScreen or MainAppShell
      home: const AuthGate(),
    );
  }
}
