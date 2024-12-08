import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../main.dart'; // Import the main.dart to access the global theme control

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  void _calculateTotals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsString = prefs.getString('transactions');
    List<dynamic> transactions =
        transactionsString != null ? json.decode(transactionsString) : [];

    double income = 0.0;
    double expense = 0.0;

    for (var transaction in transactions) {
      if (transaction['type'] == 'Income') {
        income += transaction['amount'];
      } else if (transaction['type'] == 'Expense') {
        expense += transaction['amount'];
      }
    }

    setState(() {
      _totalIncome = income;
      _totalExpense = expense;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Manager',
          style: TextStyle(fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              // Use the global key to switch themes
              final currentTheme = Theme.of(context).brightness;
              MyApp.state.setTheme(
                currentTheme == Brightness.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Welcome to Expense Manager!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
            ),
            SizedBox(height: 20),
            // Financial Summary
            Card(
              elevation: 4,
              child: ListTile(
                title: Text('Total Balance',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '\$${(_totalIncome - _totalExpense).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              child: ListTile(
                title: Text('Total Income',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '\$${_totalIncome.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, color: Colors.green),
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              child: ListTile(
                title: Text('Total Expense',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '\$${_totalExpense.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, color: Colors.red),
                ),
              ),
            ),
            SizedBox(height: 32),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add-transaction');
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Transaction'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/transaction-list');
                  },
                  icon: Icon(Icons.list),
                  label: Text('View Transactions'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
