import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_code/config/theme/app_theme.dart';

void main() {
  group('AppTheme color constants', () {
    test('should have correct primaryColor value', () {
      // Arrange & Act & Assert
      expect(AppTheme.primaryColor, const Color(0xFF1A0047));
    });

    test('should have correct accentColor value', () {
      expect(AppTheme.accentColor, const Color(0xFF4233CE));
    });

    test('should have correct background value', () {
      expect(AppTheme.background, const Color(0xFF0F0035));
    });

    test('should have correct surface value', () {
      expect(AppTheme.surface, const Color(0xFF1A0050));
    });

    test('should have correct cardColor value', () {
      expect(AppTheme.cardColor, const Color(0xFF220A5A));
    });

    test('should have correct navBar value', () {
      expect(AppTheme.navBar, const Color(0xFF110038));
    });

    test('should have correct successColor value', () {
      expect(AppTheme.successColor, const Color(0xFF4CAF82));
    });

    test('should have correct dangerColor value', () {
      expect(AppTheme.dangerColor, const Color(0xFFE05A7A));
    });

    test('should have correct textSecondary value', () {
      expect(AppTheme.textSecondary, const Color(0xFFAA99D8));
    });
  });

  group('AppTheme.themeData', () {
    test('should return a ThemeData with dark brightness', () {
      // Arrange & Act
      final theme = AppTheme.themeData;

      // Assert
      expect(theme.brightness, Brightness.dark);
    });

    test('should have transparent AppBar background', () {
      // Arrange & Act
      final theme = AppTheme.themeData;

      // Assert
      expect(theme.appBarTheme.backgroundColor, Colors.transparent);
    });

    test('should have scaffoldBackgroundColor equal to background', () {
      // Arrange & Act
      final theme = AppTheme.themeData;

      // Assert
      expect(theme.scaffoldBackgroundColor, AppTheme.background);
    });
  });
}
