import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _showSplash = prefs.getBool('showSplash') ?? true; // Default to true
    });
  }

  void _toggleDarkMode(bool value) async {
    setState(() {
      _darkMode = value;
    });

    // Update the app's theme dynamically
    MyApp.state.setTheme(value ? ThemeMode.dark : ThemeMode.light);

    // Save the theme preference
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }

  void _toggleSplashScreen(bool value) async {
    setState(() {
      _showSplash = value;
    });

    // Save the splash screen preference
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showSplash', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _darkMode,
            onChanged: _toggleDarkMode,
          ),
          SwitchListTile(
            title: const Text('Show Splash Screen'),
            value: _showSplash,
            onChanged: _toggleSplashScreen,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About App'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('About Expense Manager'),
                    content: const Text(
                      'Expense Manager is a simple app designed to help you track your income and expenses. Version 1.0.0.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
