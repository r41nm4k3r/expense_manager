import 'package:expense_manager/screens/currency_converter_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_manager/screens/settings_screen.dart';
import './screens/dashboard_screen.dart';
import './screens/add_transaction_screen.dart';
import './screens/transaction_list_screen.dart';
import './screens/reports_screen.dart';
import './screens/splash_screen.dart'; // Import the Splash Screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static late _MyAppState state;

  const MyApp({super.key});

  @override
  _MyAppState createState() {
    state = _MyAppState();
    return state;
  }
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void setTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      debugShowCheckedModeBanner: false, // Disable the debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: const StartupScreen(), // Updated to use the StartupScreen
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/add-transaction': (context) => const AddTransactionScreen(),
        '/transaction-list': (context) => const TransactionListScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/currency-converter': (context) => const CurrencyConverterPage(),
        '/reports': (context) => const ReportsScreen(),
      },
    );
  }
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  _StartupScreenState createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _checkSplashPreference();
  }

  Future<void> _checkSplashPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? showSplash = prefs.getBool('showSplash');
    setState(() {
      _showSplash = showSplash ?? true; // Default to true if not set
    });

    if (!_showSplash) {
      _navigateToDashboard();
    } else {
      Future.delayed(const Duration(seconds: 3), _navigateToDashboard);
    }
  }

  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return _showSplash ? const SplashScreen() : const SizedBox.shrink();
  }
}
