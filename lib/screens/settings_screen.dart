import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
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

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: _darkMode,
            onChanged: _toggleDarkMode,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About App'),
            subtitle: Text('Version 1.0.0'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('About Expense Manager'),
                    content: Text(
                      'Expense Manager is a simple app designed to help you track your income and expenses. Version 1.0.0.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Close'),
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
