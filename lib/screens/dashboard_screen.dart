import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart'; // Import FLChart package
import '../main.dart'; // Import the main.dart to access the global theme control

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Income', 'amount': 0.0, 'color': Colors.green},
    {'name': 'Expense', 'amount': 0.0, 'color': Colors.red},
  ];
  final List<Map<String, dynamic>> _categoryDetails = [
    {
      'name': 'Food',
      'amount': 0.0,
      'color': Colors.purple,
      'icon': Icons.fastfood
    },
    {
      'name': 'Groceries',
      'amount': 0.0,
      'color': Colors.blue,
      'icon': Icons.shopping_cart
    },
    {
      'name': 'Utilities',
      'amount': 0.0,
      'color': Colors.orange,
      'icon': Icons.tv
    },
    {
      'name': 'Entertainment',
      'amount': 0.0,
      'color': Colors.red,
      'icon': Icons.movie
    },
    {
      'name': 'Salary',
      'amount': 0.0,
      'color': Colors.green,
      'icon': Icons.monetization_on
    },
    {
      'name': 'Investment',
      'amount': 0.0,
      'color': Colors.teal,
      'icon': Icons.account_balance
    },
    {
      'name': 'Other',
      'amount': 0.0,
      'color': Colors.grey,
      'icon': Icons.account_balance
    },
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
            const SizedBox(width: 8), // Space between logo and title
            const Text(
              'Xpense Manager',
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
            icon: const Icon(Icons.menu),
            onPressed: _openMenu,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
              const SizedBox(height: 20),
// Income vs Expense Pie Chart
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 0,
                            sections: [
                              PieChartSectionData(
                                color: _categories[0]['color'],
                                value: _totalIncome,
                                radius: 50,
                                title:
                                    '${((_totalIncome / (_totalIncome + _totalExpense)) * 100).toStringAsFixed(1)}%', // Percentage inside the pie
                                titleStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              PieChartSectionData(
                                color: _categories[1]['color'],
                                value: _totalExpense,
                                radius: 50,
                                title:
                                    '${((_totalExpense / (_totalIncome + _totalExpense)) * 100).toStringAsFixed(1)}%', // Percentage inside the pie
                                titleStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Income vs Expense',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      // Income and Expense Amounts Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.monetization_on,
                                  color: Colors.green),
                              const SizedBox(height: 8),
                              Text(
                                '\$${_totalIncome.toStringAsFixed(2)}', // Amount
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.green),
                              ),
                              const Text('Income'),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.money_off, color: Colors.red),
                              const SizedBox(height: 8),
                              Text(
                                '\$${_totalExpense.toStringAsFixed(2)}', // Amount
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.red),
                              ),
                              const Text('Expense'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

// Expense Breakdown Pie Chart
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 0,
                            sections: _categoryDetails.map((category) {
                              double percentage = (category['amount'] /
                                      _categoryDetails.fold(
                                          0.0,
                                          (prev, element) =>
                                              prev + element['amount'])) *
                                  100;
                              return PieChartSectionData(
                                color: category['color'],
                                value: category['amount'],
                                radius: 50,
                                title:
                                    '${percentage.toStringAsFixed(1)}%', // Percentage inside the pie
                                titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Expense Breakdown',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      // Legend
                      Column(
                        children: _categoryDetails.map((category) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                color: category['color'],
                              ),
                              const SizedBox(width: 8),
                              Icon(category['icon'], color: category['color']),
                              const SizedBox(width: 8),
                              Text(
                                '${category['name']} - \$${category['amount'].toStringAsFixed(2)}', // Amount next to category
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              // Other Dashboard Cards
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: ListTile(
                  title: const Text('Total Balance',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '\$${(_totalIncome - _totalExpense).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: ListTile(
                  title: const Text('Total Income',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '\$${_totalIncome.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: ListTile(
                  title: const Text('Total Expense',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '\$${_totalExpense.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-transaction')
                          .then((_) => _calculateTotals());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Transaction'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/transaction-list')
                          .then((_) => _calculateTotals());
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('View Transactions'),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Add some space before the footer
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
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
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context); // Close the menu
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Transaction'),
              onTap: () {
                Navigator.pop(context); // Close the menu
                Navigator.pushNamed(context, '/add-transaction')
                    .then((_) => _calculateTotals());
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Transaction List'),
              onTap: () {
                Navigator.pop(context); // Close the menu
                Navigator.pushNamed(context, '/transaction-list')
                    .then((_) => _calculateTotals());
              },
            ),
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Currency Converter'),
              onTap: () {
                Navigator.pop(context); // Close the menu
                Navigator.pushNamed(context, '/currency-converter');
              },
            ),
            // Settings menu item
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the menu
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
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
          title: const Text('About'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                logoPath,
                width: 60,
                height: 60,
              ),
              const SizedBox(height: 16),
              const Text(
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
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
