import 'package:flutter/material.dart';

// FinTrack Color Palette
class AppColors {
  // Brand Colors
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF0D9488);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color incomeLight = Color(0xFF10B981);
  static const Color incomeDark = Color(0xFF34D399);
  static const Color expenseLight = Color(0xFFEF4444);
  static const Color expenseDark = Color(0xFFF87171);
  static const Color warningLight = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color dangerLight = Color(0xFFDC2626);
  static const Color dangerDark = Color(0xFFEF4444);

  // Neutral Palette
  static const Color backgroundLight = Color(0xFFF1F5F9);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceCardLight = Color(0xFFFFFFFF);
  static const Color surfaceCardDark = Color(0xFF1E293B);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF334155);
}

// FinTrack Typography
class AppTextStyles {
  static const String fontFamily = 'Roboto'; // Material default

  static const TextStyle displayLarge = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
  );
}

// FinTrack Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  static const double screenHorizontalPadding = 16.0;
  static const double screenVerticalPadding = 24.0;
  static const double cardPadding = 20.0;
  static const double borderRadius = 10.0;
}

// FinTrack Theme Data
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppTextStyles.fontFamily,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.incomeLight, // Explicitly set secondary for income
      background: AppColors.backgroundLight,
      surface: AppColors.surfaceCardLight,
      onSurface: AppColors.textPrimaryLight,
      error: AppColors.dangerLight,
      onError: AppColors.onPrimary,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    cardColor: AppColors.surfaceCardLight,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      titleMedium: AppTextStyles.titleMedium.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textSecondaryLight,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      color: AppColors.surfaceCardLight,
      margin: EdgeInsets.zero, // Ensure no default margin
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        textStyle: AppTextStyles.titleMedium,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceCardLight,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.textSecondaryLight,
      elevation: 8.0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: AppTextStyles.labelSmall,
      unselectedLabelStyle: AppTextStyles.labelSmall,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0.0,
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textPrimaryLight,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimaryLight,
      ),
      centerTitle: false,
    ),
    dividerColor: AppColors.dividerLight,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppTextStyles.fontFamily,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.incomeDark, // Explicitly set secondary for income
      background: AppColors.backgroundDark,
      surface: AppColors.surfaceCardDark,
      onSurface: AppColors.textPrimaryDark,
      error: AppColors.dangerDark,
      onError: AppColors.onPrimary,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.surfaceCardDark,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      titleMedium: AppTextStyles.titleMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textSecondaryDark,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      color: AppColors.surfaceCardDark,
      margin: EdgeInsets.zero, // Ensure no default margin
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        textStyle: AppTextStyles.titleMedium,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceCardDark,
      selectedItemColor: AppColors.primaryDark,
      unselectedItemColor: AppColors.textSecondaryDark,
      elevation: 8.0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: AppTextStyles.labelSmall,
      unselectedLabelStyle: AppTextStyles.labelSmall,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0.0,
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textPrimaryDark,
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      centerTitle: false,
    ),
    dividerColor: AppColors.dividerDark,
  );
}
