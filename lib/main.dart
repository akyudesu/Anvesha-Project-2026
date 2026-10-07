import 'package:fire_evacuation_app/features/dashboard/presentation/home.dart';
import 'package:fire_evacuation_app/features/login/presentation/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _backgroundColor = Color(0xFF0A121A);
const _surfaceColor = Color(0xFF0E2032);
const _accentColor = Color(0xFF5CB5F2);
const _fireColor = Color(0xFFE63946);
const _mutedTextColor = Color(0xFF8A9AAD);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://fwwftbcjcftavbnmvhkp.supabase.co',
    ),
    publishableKey: const String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
      defaultValue: 'sb_publishable_flwOIu5K6BL-vFQ96QZHqA_Mt_XkKte',
    ),
  );
  runApp(
    MyApp(initiallyAuthenticated: Supabase.instance.client.auth.currentSession != null),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initiallyAuthenticated = false});

  final bool initiallyAuthenticated;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fire evacuation system',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: _accentColor,
          onPrimary: _backgroundColor,
          secondary: _fireColor,
          onSecondary: Colors.white,
          surface: _surfaceColor,
          onSurface: Colors.white,
          error: _fireColor,
        ),
        scaffoldBackgroundColor: _backgroundColor,
        textTheme:
            GoogleFonts.interTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme,
            ).copyWith(
              displayLarge: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              displayMedium: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              displaySmall: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              headlineLarge: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              headlineMedium: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              headlineSmall: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              titleLarge: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              titleMedium: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              titleSmall: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: _mutedTextColor,
              ),
            ),
        iconTheme: const IconThemeData(color: _mutedTextColor),
        appBarTheme: const AppBarTheme(
          backgroundColor: _backgroundColor,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: _surfaceColor,
          surfaceTintColor: Colors.transparent,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black.withValues(alpha: 0.2),
          hintStyle: const TextStyle(color: Color(0xFF627285)),
          labelStyle: const TextStyle(color: _mutedTextColor),
          prefixIconColor: _mutedTextColor,
          suffixIconColor: _mutedTextColor,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accentColor, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _fireColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _fireColor.withValues(alpha: 0.35),
            disabledForegroundColor: Colors.white60,
            textStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _accentColor,
            foregroundColor: _backgroundColor,
            disabledBackgroundColor: _accentColor.withValues(alpha: 0.35),
            disabledForegroundColor: Colors.white60,
            textStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _accentColor,
            textStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(color: _accentColor.withValues(alpha: 0.65)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _accentColor,
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(foregroundColor: _accentColor),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _fireColor,
          foregroundColor: Colors.white,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: _surfaceColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          contentTextStyle: GoogleFonts.inter(color: _mutedTextColor),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _surfaceColor,
          contentTextStyle: GoogleFonts.inter(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: _surfaceColor,
          selectedColor: _accentColor.withValues(alpha: 0.2),
          secondarySelectedColor: _fireColor.withValues(alpha: 0.2),
          labelStyle: GoogleFonts.inter(color: Colors.white),
          secondaryLabelStyle: GoogleFonts.inter(color: _fireColor),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: _mutedTextColor,
          textColor: Colors.white,
          tileColor: Colors.transparent,
        ),
        dividerTheme: DividerThemeData(
          color: Colors.white.withValues(alpha: 0.12),
          thickness: 1,
          space: 1,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _accentColor;
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(_backgroundColor),
          side: const BorderSide(color: _mutedTextColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _accentColor;
            return _mutedTextColor;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return _accentColor.withValues(alpha: 0.35);
            }
            return _surfaceColor;
          }),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: _accentColor,
          linearTrackColor: _surfaceColor,
          circularTrackColor: _surfaceColor,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _surfaceColor,
          selectedItemColor: _accentColor,
          unselectedItemColor: _mutedTextColor,
          type: BottomNavigationBarType.fixed,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _surfaceColor,
          indicatorColor: _accentColor.withValues(alpha: 0.2),
          surfaceTintColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: _accentColor,
          unselectedLabelColor: _mutedTextColor,
          indicatorColor: _accentColor,
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 12),
        ),
      ),
      home: initiallyAuthenticated ? const Dashboard() : const Login(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute<void>(
              builder: (_) => const Login(),
              settings: settings,
            );
          case '/dashboard':
            final isAuthenticated =
                Supabase.instance.client.auth.currentSession != null;
            return MaterialPageRoute<void>(
              builder: (_) =>
                  isAuthenticated ? const Dashboard() : const Login(),
              settings: settings,
            );
          default:
            return MaterialPageRoute<void>(
              builder: (_) => const Login(),
              settings: settings,
            );
        }
      },
    );
  }
}
