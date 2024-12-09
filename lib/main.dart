import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './screens/dashboard_screen.dart';
import './screens/add_transaction_screen.dart';
import './screens/transaction_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static late _MyAppState state;

  @override
  _MyAppState createState() {
    state = _MyAppState();
    return state;
  }
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void setTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
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
      initialRoute: '/',
      routes: {
        '/': (context) => DashboardScreen(),
        '/add-transaction': (context) => AddTransactionScreen(),
        '/transaction-list': (context) => TransactionListScreen(),
      },
    );
  }
}
