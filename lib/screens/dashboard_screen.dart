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
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateTotals());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About Expense Manager'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Expense Manager v1.0\n\nA simple and intuitive app to manage your finances effectively. Track your income and expenses to maintain control over your budget.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card, size: 32, color: Colors.blue),
                  SizedBox(width: 8),
                  Icon(Icons.attach_money, size: 32, color: Colors.green),
                  SizedBox(width: 8),
                  Icon(Icons.analytics, size: 32, color: Colors.purple),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context); // Close the menu
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Transaction'),
              onTap: () {
                Navigator.pop(context); // Close the menu
                Navigator.pushNamed(context, '/add-transaction')
                    .then((_) => _calculateTotals());
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Transaction List'),
              onTap: () {
                Navigator.pop(context); // Close the menu
                Navigator.pushNamed(context, '/transaction-list')
                    .then((_) => _calculateTotals());
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
          ],
        );
      },
    );
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
              final currentTheme = Theme.of(context).brightness;
              MyApp.state.setTheme(
                currentTheme == Brightness.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: _openMenu,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Expense Manager!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
            ),
            SizedBox(height: 20),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add-transaction')
                        .then((_) => _calculateTotals());
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Transaction'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/transaction-list')
                        .then((_) => _calculateTotals());
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
