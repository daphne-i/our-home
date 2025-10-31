import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// This file contains all the theme and styling logic for the Homely app.
/// It's based on the "Kickass UI" section of the design document.
/// It uses Material 3 and Google Fonts (Poppins & Inter).

class AppTheme {
  // --- Spacing constants (from design doc) ---
  static const double spacingUnit = 8.0;
  static const double spacingSmall = spacingUnit; // 8.0
  static const double spacingMedium = spacingUnit * 2; // 16.0
  static const double spacingLarge = spacingUnit * 3; // 24.0

  // --- Border radius constants (from design doc) ---
  static final BorderRadius cardRadius = BorderRadius.circular(16.0);
  static final BorderRadius fieldRadius = BorderRadius.circular(12.0);
  static final BorderRadius buttonRadius = BorderRadius.circular(12.0);

  // --- Typography (from design doc) ---
  static final TextTheme _baseTextTheme = ThemeData.light().textTheme;

  static final TextTheme _textTheme = GoogleFonts.interTextTheme(
    _baseTextTheme,
  ).copyWith(
    // Poppins for headings
    displayLarge: GoogleFonts.poppins(
      textStyle: _baseTextTheme.displayLarge,
      fontWeight: FontWeight.bold,
      fontSize: 32,
    ),
    headlineMedium: GoogleFonts.poppins(
      textStyle: _baseTextTheme.headlineMedium,
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
    // Poppins for card titles
    titleMedium: GoogleFonts.poppins(
      textStyle: _baseTextTheme.titleMedium,
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
    // Inter for body
    bodyLarge: GoogleFonts.inter(
      textStyle: _baseTextTheme.bodyLarge,
      fontSize: 16,
    ),
    bodyMedium: GoogleFonts.inter(
      textStyle: _baseTextTheme.bodyMedium,
      fontSize: 14,
    ),
    // Inter for labels/captions
    labelSmall: GoogleFonts.inter(
      textStyle: _baseTextTheme.labelSmall,
      fontSize: 12,
    ),
  );

  // --- THEME A: "Summer Ocean Breeze" ---

  static const _oceanLightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFE63946), // Bright Red
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF457B9D), // Medium Blue
    onSecondary: Color(0xFFFFFFFF),
    surface: Color(0xFFF1FAEE), // Off-White/Cream (was background)
    onSurface: Color(0xFF1D3557), // Darkest Blue (was onBackground)
    surfaceContainerHighest: Color(0xFFFFFFFF), // Pure White (was surface)
    onSurfaceVariant: Color(0xFFA8DADC), // Light Blue
    error: Color(0xFFB00020),
    onError: Color(0xFFFFFFFF),
  );

  static const _oceanDarkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFE63946), // Bright Red
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFA8DADC), // Light Blue
    onSecondary: Color(0xFF1D3557),
    surface: Color(0xFF1D3557), // Darkest Blue (was background)
    onSurface: Color(0xFFF1FAEE), // Off-White/Cream (was onBackground)
    surfaceContainerHighest:
        Color(0xFF29486F), // Lighter Grey-Blue (was surface)
    onSurfaceVariant: Color(0xFFA8DADC), // Light Blue
    error: Color(0xFFCF6679),
    onError: Color(0xFF000000),
  );

  // --- THEME B: "Neutral Elegance" ---

  static const _neutralLightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFE0BBAA), // Dusty Rose/Peach
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF4B4340), // Darkest Brown
    onSecondary: Color(0xFFFFFFFF),
    surface: Color(0xFFF5F3F1), // Off-White/Cream (was background)
    onSurface: Color(0xFF4B4340), // Darkest Brown (was onBackground)
    surfaceContainerHighest: Color(0xFFFFFFFF), // Pure White (was surface)
    onSurfaceVariant: Color(0xFF9B928E), // Greige/Taupe
    error: Color(0xFFB00020),
    onError: Color(0xFFFFFFFF),
  );

  static const _neutralDarkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFE0BBAA), // Dusty Rose/Peach
    onPrimary: Color(0xFF4B4340),
    secondary: Color(0xFFCAC3BF), // Lightest Greige
    onSecondary: Color(0xFF4B4340),
    surface: Color(0xFF4B4340), // Darkest Brown (was background)
    onSurface: Color(0xFFF5F3F1), // Off-White/Cream (was onBackground)
    surfaceContainerHighest: Color(0xFF9B928E), // Greige/Taupe (was surface)
    onSurfaceVariant: Color(0xFFCAC3BF), // Lightest Greige
    error: Color(0xFFCF6679),
    onError: Color(0xFF000000),
  );

  // --- Central Theme Builder ---

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // --- WIDGET THEMES (from design doc) ---

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0.0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        scrolledUnderElevation: 2.0, // Subtle shadow on scroll
        titleTextStyle: _textTheme.headlineMedium,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 1.0,
        shape: RoundedRectangleBorder(borderRadius: cardRadius),
        color: colorScheme.surfaceContainerHighest,
        margin: const EdgeInsets.symmetric(
          vertical: spacingSmall,
          horizontal: spacingMedium,
        ),
      ),

      // Text Field Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.onSurface.withAlpha(13), // 0.05 opacity
        border: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        labelStyle: _textTheme.bodyMedium,
        hintStyle: _textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Bottom Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0.0,
        backgroundColor: colorScheme.surfaceContainerHighest,
        indicatorColor: colorScheme.primary.withAlpha(51), // 0.2 opacity
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.all(
          _textTheme.labelSmall?.copyWith(fontSize: 12),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),

      // Button Themes
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
          padding: const EdgeInsets.symmetric(
            vertical: spacingMedium,
            horizontal: spacingLarge,
          ),
          textStyle:
              _textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle:
              _textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- PUBLIC THEMES ---

  /// "Summer Ocean Breeze" - Light Mode
  static ThemeData get oceanLightTheme => _buildTheme(_oceanLightColorScheme);

  /// "Summer Ocean Breeze" - Dark Mode
  static ThemeData get oceanDarkTheme => _buildTheme(_oceanDarkColorScheme);

  /// "Neutral Elegance" - Light Mode
  static ThemeData get neutralLightTheme =>
      _buildTheme(_neutralLightColorScheme);

  /// "Neutral Elegance" - Dark Mode
  static ThemeData get neutralDarkTheme => _buildTheme(_neutralDarkColorScheme);
}
