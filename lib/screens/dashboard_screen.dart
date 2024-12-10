import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart'; // Import FLChart package
import '../main.dart'; // Import the main.dart to access the global theme control

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  List<Map<String, dynamic>> _categories = [
    {'name': 'Income', 'amount': 0.0, 'color': Colors.green},
    {'name': 'Expense', 'amount': 0.0, 'color': Colors.red},
  ];
  List<Map<String, dynamic>> _categoryDetails = [
    {'name': 'Groceries', 'amount': 0.0, 'color': Colors.blue},
    {'name': 'Utilities', 'amount': 0.0, 'color': Colors.orange},
    {'name': 'Entertainment', 'amount': 0.0, 'color': Colors.purple},
    {'name': 'Salary', 'amount': 0.0, 'color': Colors.green},
    {'name': 'Investment', 'amount': 0.0, 'color': Colors.teal},
  ];

  final String logoPath = 'assets/images/logo.png'; // Path to your logo

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

    // Reset category amounts before recalculating
    for (var category in _categoryDetails) {
      category['amount'] = 0.0; // Reset category amounts
    }

    // Calculate totals for income, expense, and categories
    for (var transaction in transactions) {
      if (transaction['type'] == 'Income') {
        income += transaction['amount'];
      } else if (transaction['type'] == 'Expense') {
        expense += transaction['amount'];
        // Add to the category total
        for (var category in _categoryDetails) {
          if (category['name'] == transaction['category']) {
            category['amount'] += transaction['amount'];
          }
        }
      }
    }

    setState(() {
      _totalIncome = income;
      _totalExpense = expense;
      _categories[0]['amount'] = income;
      _categories[1]['amount'] = expense;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Logo Image in the AppBar
            Image.asset(
              logoPath,
              width: 30, // Adjust the size of the logo
              height: 30, // Adjust the size of the logo
            ),
            SizedBox(width: 8), // Space between logo and title
            Text(
              'Expense Manager',
              style: TextStyle(fontSize: 24),
            ),
          ],
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
            // Both charts side by side in the same card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Pie chart for income vs expense
                    Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 0,
                              sections: [
                                PieChartSectionData(
                                  color: _categories[0]['color'],
                                  value: _totalIncome,
                                  title: 'Income',
                                  radius: 50,
                                  titleStyle: TextStyle(color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: _categories[1]['color'],
                                  value: _totalExpense,
                                  title: 'Expense',
                                  radius: 50,
                                  titleStyle: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Income vs Expense',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    // Pie chart for categories
                    Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 0,
                              sections: _categoryDetails.map((category) {
                                return PieChartSectionData(
                                  color: category['color'],
                                  value: category['amount'],
                                  title: category['name'],
                                  radius: 50,
                                  titleStyle: TextStyle(color: Colors.white),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Expense Breakdown',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
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
            SizedBox(height: 16), // Add some space before the footer
            // Footer Section with Text and Icons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Made with ',
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(
                      Icons.flutter_dash,
                      color: Colors.blue,
                      size: 20,
                    ),
                    Text(
                      ' and ',
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
            // Settings menu item
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the menu
                Navigator.pushNamed(context, '/settings');
              },
            ),
            // About menu item, now with pop-up
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context); // Close the menu
                _showAboutDialog(); // Show the about pop-up
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show the About dialog
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('About'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                logoPath,
                width: 60,
                height: 60,
              ),
              SizedBox(height: 16),
              Text(
                'Expense Manager App\nVersion 1.0.0\nBuilt with Flutter',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
