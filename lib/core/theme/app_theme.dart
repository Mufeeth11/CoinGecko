import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF0A0B09);
  static const surface = Color(0xFF111310);
  static const surfaceElevated = Color(0xFF171A15);
  static const surfaceSoft = Color(0xFF20251E);
  static const border = Color(0xFF2A3027);
  static const primary = Color(0xFFC9F26B);
  static const primaryDim = Color(0xFF9CC44A);
  static const secondary = Color(0xFF86A9FF);
  static const positive = Color(0xFF6FE3B0);
  static const negative = Color(0xFFFF7A66);
  static const warning = Color(0xFFF0C05A);
  static const text = Color(0xFFECEEE5);
  static const muted = Color(0xFF9BA394);
  static const faint = Color(0xFF6D7568);
  static const white = Colors.white;
}

abstract final class AppGradients {
  static const primary = LinearGradient(
    colors: [Color(0xFFD8FF86), Color(0xFFB4E04A)],
    stops: [0, 1],
  );

  static const chartFill = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x33C9F26B), Color(0x00C9F26B)],
  );

  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF171C13), Color(0xFF0C0E0A)],
  );
}

abstract final class AppText {
  static const sansFamily = 'Segoe UI';
  static const sansFallback = <String>[
    'Roboto',
    'Helvetica Neue',
    'Arial',
  ];
  static const monoFamily = 'Consolas';
  static const monoFallback = <String>[
    'Menlo',
    'Roboto Mono',
    'DejaVu Sans Mono',
    'Courier New',
    'monospace',
  ];

  static TextStyle sans({
    double? size,
    FontWeight? weight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: sansFamily,
      fontFamilyFallback: sansFallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  static TextStyle display({
    double size = 30,
    Color? color,
    FontWeight weight = FontWeight.w800,
    double spacing = -1.1,
    double height = 1.0,
  }) {
    return TextStyle(
      fontFamily: sansFamily,
      fontFamilyFallback: sansFallback,
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.text,
      letterSpacing: spacing,
      height: height,
    );
  }

  static TextStyle mono({
    double? size,
    FontWeight? weight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: monoFamily,
      fontFamilyFallback: monoFallback,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle eyebrow([Color? color]) => mono(
    size: 9.5,
    weight: FontWeight.w700,
    color: color ?? AppColors.faint,
    letterSpacing: 1.5,
  );
}

class AppTheme {
  const AppTheme._();

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.background,
      secondary: AppColors.secondary,
      onSecondary: AppColors.background,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      error: AppColors.negative,
      onError: AppColors.background,
      outline: AppColors.border,
    );

    final base = ThemeData.dark().textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
      fontFamily: AppText.sansFamily,
      fontFamilyFallback: AppText.sansFallback,
    );

    final textTheme = base.copyWith(
      displayLarge: AppText.display(size: 46, spacing: -2),
      displayMedium: AppText.display(size: 38, spacing: -1.6),
      displaySmall: AppText.display(size: 32, spacing: -1.3),
      headlineLarge: AppText.display(size: 30, spacing: -1.1),
      headlineMedium: AppText.display(size: 26, spacing: -0.9),
      headlineSmall: AppText.display(size: 22, spacing: -0.7),
      titleLarge: AppText.sans(
        size: 18,
        weight: FontWeight.w700,
        color: AppColors.text,
        letterSpacing: -0.3,
      ),
      titleMedium: AppText.sans(
        size: 14,
        weight: FontWeight.w600,
        color: AppColors.text,
        letterSpacing: -0.1,
      ),
      titleSmall: AppText.sans(
        size: 12,
        weight: FontWeight.w600,
        color: AppColors.text,
        letterSpacing: 0.2,
      ),
      bodyLarge: AppText.sans(
        size: 14,
        color: AppColors.muted,
        height: 1.5,
      ),
      bodyMedium: AppText.sans(
        size: 12.5,
        color: AppColors.muted,
        height: 1.5,
      ),
      bodySmall: AppText.sans(
        size: 11,
        color: AppColors.faint,
        height: 1.45,
      ),
      labelLarge: AppText.sans(
        size: 11.5,
        weight: FontWeight.w700,
        color: AppColors.text,
        letterSpacing: 0.5,
      ),
      labelMedium: AppText.mono(
        size: 10,
        weight: FontWeight.w600,
        color: AppColors.muted,
        letterSpacing: 0.8,
      ),
      labelSmall: AppText.mono(
        size: 9,
        weight: FontWeight.w600,
        color: AppColors.faint,
        letterSpacing: 0.8,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 60,
        iconTheme: const IconThemeData(color: AppColors.text, size: 20),
        titleTextStyle: AppText.sans(
          size: 17,
          weight: FontWeight.w700,
          color: AppColors.text,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppText.sans(size: 12.5, color: AppColors.faint),
        helperStyle: AppText.sans(size: 10.5, color: AppColors.faint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        prefixIconColor: AppColors.muted,
        suffixIconColor: AppColors.muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: AppColors.primary.withValues(alpha: 0.1),
        disabledColor: AppColors.surfaceSoft,
        showCheckmark: false,
        side: const BorderSide(color: AppColors.border),
        shape: const StadiumBorder(),
        labelStyle: AppText.mono(
          size: 10,
          weight: FontWeight.w600,
          color: AppColors.muted,
          letterSpacing: 0.4,
        ),
        secondaryLabelStyle: AppText.mono(
          size: 10,
          weight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: AppText.sans(
            size: 11.5,
            weight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.border),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          textStyle: AppText.sans(
            size: 11.5,
            weight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: const StadiumBorder(),
          textStyle: AppText.sans(
            size: 11.5,
            weight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.text, size: 20),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        space: 1,
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        height: 66,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppText.mono(
            size: 9,
            weight: FontWeight.w700,
            letterSpacing: 1.1,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.faint,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.muted,
            size: 20,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.surface,
        showDragHandle: false,
        dragHandleColor: AppColors.border,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: AppText.sans(
          size: 12,
          color: AppColors.text,
          height: 1.4,
        ),
        actionTextColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceSoft,
        circularTrackColor: AppColors.surfaceSoft,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.muted,
        textColor: AppColors.text,
        titleTextStyle: AppText.sans(
          size: 13,
          weight: FontWeight.w600,
          color: AppColors.text,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.faint,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border),
        ),
        textStyle: AppText.mono(size: 10, color: AppColors.text),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: Color(0x33C9F26B),
        selectionHandleColor: AppColors.primary,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppText.sans(size: 12.5, color: AppColors.text),
        inputDecorationTheme: const InputDecorationTheme(filled: true),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
