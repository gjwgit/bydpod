/// BYD brand theme: light and dark ColorScheme and component styles.
///
// Time-stamp: <Monday 2026-03-16 22:01:12 +1100 Graham Williams>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Claude, Graham Williams

library;

import 'package:flutter/material.dart';

/// BYD Ocean series palette — the range the Sealion 7 belongs to: deep ocean
/// navy hull, azure highlight, and greys tinted towards blue rather than the
/// neutral/violet Material defaults.

class BydColors {
  static const Color primary = Color(0xFF002B5C);
  // Deeper hull navy, for the dark-theme app bar and surfaces that would
  // otherwise sit too close to the primary.
  static const Color primaryDeep = Color(0xFF001B3D);
  static const Color accent = Color(0xFF00A0E9);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFEEF2F7);
  static const Color midGrey = Color(0xFFA7B2C2);
  static const Color darkGrey = Color(0xFF33405A);
  static const Color success = Color(0xFF00C08B);
  static const Color warning = Color(0xFFFFB400);
  static const Color error = Color(0xFFE8003D);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color scaffoldBg = Color(0xFFEDF1F7);

  // Dark-theme ramp, all tinted navy so the dark app reads as the same brand
  // as the light one.

  static const Color darkScaffold = Color(0xFF0A1626);
  static const Color darkSurface = Color(0xFF122033);
  static const Color darkSurfaceHigh = Color(0xFF1B2C42);
  static const Color darkOutline = Color(0xFF27394F);
  static const Color darkBorder = Color(0xFF354A64);
}

ThemeData bydLightTheme() => bydTheme(Brightness.light);
ThemeData bydDarkTheme() => bydTheme(Brightness.dark);

ThemeData bydTheme([Brightness brightness = Brightness.light]) {
  final isDark = brightness == Brightness.dark;

  final colorScheme = isDark
      ? const ColorScheme.dark(
          primary: BydColors.accent,
          secondary: BydColors.primary,
          surface: BydColors.darkSurface,
          surfaceContainerHighest: BydColors.darkSurfaceHigh,
          onSurface: Colors.white,
          onSurfaceVariant: BydColors.midGrey,
          outlineVariant: BydColors.darkOutline,
          error: BydColors.error,
        )
      : ColorScheme.fromSeed(
          seedColor: BydColors.primary,
          primary: BydColors.primary,
          secondary: BydColors.accent,
          surface: BydColors.cardBg,
          error: BydColors.error,
          brightness: Brightness.light,
        );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor:
        isDark ? BydColors.darkScaffold : BydColors.scaffoldBg,
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? BydColors.primaryDeep : BydColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: isDark ? BydColors.darkSurface : BydColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BydColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      fillColor: isDark ? BydColors.darkSurfaceHigh : BydColors.lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: isDark
            ? const BorderSide(color: BydColors.darkBorder, width: 1)
            : BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: isDark
            ? const BorderSide(color: BydColors.darkBorder, width: 1)
            : BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? BydColors.accent : BydColors.primary,
          width: 2,
        ),
      ),
      labelStyle:
          TextStyle(color: isDark ? Colors.white70 : BydColors.darkGrey),
      hintStyle: TextStyle(color: isDark ? Colors.white38 : BydColors.midGrey),
      prefixIconColor: isDark ? Colors.white54 : BydColors.midGrey,
    ),
  );
}
