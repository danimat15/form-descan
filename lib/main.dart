import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config.dart';
import 'providers/survey_provider.dart';
import 'screens/login_screen.dart';
import 'screens/survey_dashboard_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final bool loggedIn = await AuthService.isLoggedIn();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SurveyProvider()..initializeProvider()),
      ],
      child: MyApp(isLoggedIn: loggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // Premium Light Theme matching Google Stitch design specifications
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF9A4600), // Primary Rust Orange
      scaffoldBackgroundColor: const Color(0xFFF1F3F5), // Light background
      cardColor: const Color(0xFFFFFFFF), // White cards
      dividerColor: const Color(0xFFDEC1B1), // Outline variant border
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF9A4600),
        primaryContainer: Color(0xFFF47A20), // Bright active orange
        onPrimary: Colors.white,
        secondary: Color(0xFF1C5FA8), // BPS Blue
        secondaryContainer: Color(0xFF79B0FF),
        onSecondary: Colors.white,
        surface: Color(0xFFF9F9FC),
        onSurface: Color(0xFF1A1C1E),
        onSurfaceVariant: Color(0xFF574237),
        outline: Color(0xFF8B7265),
        outlineVariant: Color(0xFFDEC1B1),
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF93000A),
        tertiary: Color(0xFF006E1C), // Success Green
        tertiaryContainer: Color(0xFF4DB051),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF9F9FC),
        foregroundColor: Color(0xFF9A4600),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF9A4600)),
        titleTextStyle: TextStyle(
          color: Color(0xFF9A4600),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Color(0xFF1A1C1E)),
        bodyMedium: TextStyle(color: Color(0xFF574237)), // Neutral muted
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Color(0xFF574237), fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: Color(0xFFDEC1B1)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDEC1B1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDEC1B1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF9A4600), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9A4600),
          foregroundColor: Colors.white,
          elevation: 1,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return MaterialApp(
      title: 'Pemutahiran Sosial Ekonomi 2026',
      debugShowCheckedModeBanner: false,
      theme: lightTheme, // Light mode is default as per Stitch design
      home: _getHome(context),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const SurveyDashboardScreen(),
      },
    );
  }

  Widget _getHome(BuildContext context) {
    if (isLoggedIn) {
      return const SurveyDashboardScreen();
    }
    return const LoginScreen();
  }
}
