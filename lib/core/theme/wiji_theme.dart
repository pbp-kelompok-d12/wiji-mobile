import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/theme/wiji_colors.dart';

/// Jarak bareng biar padding di semua halaman seragam.
abstract final class WijiSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

/// Tema Material buat seluruh aplikasi. Tombol, kartu, input, sama drawer
/// udah ikut warna Wiji dari sini, jadi widget di halaman cukup pakai bawaan.
abstract final class WijiTheme {
  static const radius = BorderRadius.all(Radius.circular(12));

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: WijiColors.moss,
        primary: WijiColors.forest,
        onPrimary: WijiColors.white,
        secondary: WijiColors.moss,
        onSecondary: WijiColors.white,
        tertiary: WijiColors.clay,
        error: WijiColors.brick,
        errorContainer: WijiColors.brickBg,
        surface: WijiColors.white,
        onSurface: WijiColors.ink,
        onSurfaceVariant: WijiColors.inkSoft,
        outline: WijiColors.line,
      ),
      scaffoldBackgroundColor: WijiColors.paper,
      dividerColor: WijiColors.line,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: WijiColors.ink,
        displayColor: WijiColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: WijiColors.forest,
        foregroundColor: WijiColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: WijiColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: WijiColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: WijiColors.forest,
          foregroundColor: WijiColors.white,
          minimumSize: const Size(64, 48),
          shape: const RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: WijiColors.forest,
          minimumSize: const Size(64, 48),
          side: const BorderSide(color: WijiColors.line),
          shape: const RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: WijiColors.white,
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: WijiColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: WijiColors.moss, width: 2),
        ),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: WijiColors.paper),
      listTileTheme: const ListTileThemeData(
        selectedColor: WijiColors.mossDeep,
        selectedTileColor: WijiColors.leaf,
        iconColor: WijiColors.inkSoft,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: WijiColors.forest,
        contentTextStyle: TextStyle(color: WijiColors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
