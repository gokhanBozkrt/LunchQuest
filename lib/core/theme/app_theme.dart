import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static ThemeData get light => _build();

  static ThemeData _build() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: _colorScheme,
        scaffoldBackgroundColor: AppColors.bg,

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.card,
          foregroundColor: AppColors.ink,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: AppTextStyles.h2,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.card,
          indicatorColor: AppColors.coralTint,
          height: AppTheme.navBarHeight,
          iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
                color: s.contains(WidgetState.selected)
                    ? AppColors.coral
                    : AppColors.ink3,
                size: AppDimensions.iconLG,
              )),
          labelTextStyle: WidgetStateProperty.resolveWith((s) =>
              AppTextStyles.navLabel.copyWith(
                color: s.contains(WidgetState.selected)
                    ? AppColors.coral
                    : AppColors.ink3,
              )),
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgAll,
            side: const BorderSide(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.smAll,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.smAll,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.smAll,
            borderSide: const BorderSide(color: AppColors.coral, width: 2),
          ),
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.ink3),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coral,
            foregroundColor: AppColors.onCoral,
            elevation: 0,
            minimumSize: const Size(double.infinity, AppDimensions.btnHeight),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.smAll,
            ),
            textStyle: AppTextStyles.btnLabel,
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.coral,
            side: const BorderSide(color: AppColors.coral),
            minimumSize: const Size(double.infinity, AppDimensions.btnHeight),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.smAll,
            ),
          ),
        ),

        chipTheme: ChipThemeData(
          backgroundColor: AppColors.bg,
          selectedColor: AppColors.coralTint,
          labelStyle: AppTextStyles.smallMedium,
          side: const BorderSide(color: AppColors.border),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.pillAll,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),

        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.navy,
          contentTextStyle:
              AppTextStyles.small.copyWith(color: AppColors.onNavy),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.smAll,
          ),
          behavior: SnackBarBehavior.floating,
        ),

        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),

        textTheme: const TextTheme(
          displayLarge: AppTextStyles.display,
          headlineLarge: AppTextStyles.h1,
          headlineMedium: AppTextStyles.h2,
          headlineSmall: AppTextStyles.h3,
          bodyLarge: AppTextStyles.body,
          bodyMedium: AppTextStyles.small,
          bodySmall: AppTextStyles.xs,
          labelLarge: AppTextStyles.btnLabel,
          labelMedium: AppTextStyles.smallMedium,
          labelSmall: AppTextStyles.xsMedium,
        ),
      );

  static const double navBarHeight = 64;

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.coral,
    onPrimary: AppColors.onCoral,
    primaryContainer: AppColors.coralTint,
    onPrimaryContainer: AppColors.coral700,
    secondary: AppColors.navy,
    onSecondary: AppColors.onNavy,
    secondaryContainer: AppColors.navy600,
    onSecondaryContainer: AppColors.onNavy,
    tertiary: AppColors.amber,
    onTertiary: AppColors.ink,
    tertiaryContainer: AppColors.amberTint,
    onTertiaryContainer: AppColors.ink,
    error: Color(0xFFE74C3C),
    onError: AppColors.onCoral,
    errorContainer: Color(0xFFFFEBEE),
    onErrorContainer: Color(0xFFE74C3C),
    surface: AppColors.card,
    onSurface: AppColors.ink,
    surfaceContainerHighest: AppColors.bg,
    onSurfaceVariant: AppColors.ink2,
    outline: AppColors.border,
    outlineVariant: AppColors.borderStrong,
    shadow: AppColors.shadowMd,
    scrim: AppColors.overlay45,
  );
}
