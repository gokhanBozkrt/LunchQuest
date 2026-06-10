import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  bool get isMobile => screenWidth < AppDimensions.mobileBreakpoint;
  bool get isTablet =>
      screenWidth >= AppDimensions.mobileBreakpoint &&
      screenWidth < AppDimensions.tabletBreakpoint;
  bool get isDesktop => screenWidth >= AppDimensions.tabletBreakpoint;

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }
}

extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';
}

extension DoubleExtensions on double {
  String toRatingString() => toStringAsFixed(1);
  String toDistanceString() => this < 1
      ? '${(this * 1000).toInt()}m'
      : '${toStringAsFixed(1)}km';
}

extension IntExtensions on int {
  String toReviewCount() => this >= 1000 ? '${(this / 1000).toStringAsFixed(1)}k' : toString();
}
