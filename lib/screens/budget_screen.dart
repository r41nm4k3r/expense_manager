import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'amount': 0.0, 'budget': 0.0, 'color': Colors.green},
    {
      'name': 'Entertainment',
      'amount': 0.0,
      'budget': 0.0,
      'color': Colors.blue
    },
    {'name': 'Bills', 'amount': 0.0, 'budget': 0.0, 'color': Colors.red},
  ];

  double _totalIncome = 0.0;
  double _totalSpending = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load transactions
    final String? transactionsString = prefs.getString('transactions');
    List<dynamic> transactions =
        transactionsString != null ? json.decode(transactionsString) : [];

    // Load budgets
    final String? budgetsString = prefs.getString('budgets');
    Map<String, dynamic> savedBudgets =
        budgetsString != null ? json.decode(budgetsString) : {};

    double income = 0.0;
    double spending = 0.0;

    for (var transaction in transactions) {
      if (transaction['type'] == 'Income') {
        income += transaction['amount'];
      } else if (transaction['type'] == 'Expense') {
        spending += transaction['amount'];
        final category = _categories.firstWhere(
          (cat) => cat['name'] == transaction['category'],
          orElse: () => {
            'name': 'Unknown',
            'amount': 0.0,
            'budget': 0.0,
            'color': Colors.grey
          },
        );
        setState(() {
          category['amount'] += transaction['amount'];
        });
      }
    }

    // Update category budgets
    for (var category in _categories) {
      if (savedBudgets.containsKey(category['name'])) {
        category['budget'] = savedBudgets[category['name']] ?? 0.0;
      }
    }

    setState(() {
      _totalIncome = income;
      _totalSpending = spending;
    });
  }

  void _saveCategoryBudget(Map<String, dynamic> category, double budget) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      category['budget'] = budget;
    });

    // Persist budget data
    prefs.setString('categories', json.encode(_categories));
  }

  Widget _buildBudgetChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Spending Breakdown',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _categories.map((category) {
                    return PieChartSectionData(
                      color: category['color'],
                      value: category['amount'],
                      title: '${category['amount'].toStringAsFixed(1)}',
                      radius: 50,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetList() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Categories',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Column(
              children: _categories.map((category) {
                return ListTile(
                  title: Text(category['name']),
                  subtitle: Text(
                      'Spent: \$${category['amount'].toStringAsFixed(2)} / Budget: \$${category['budget'].toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditCategoryDialog(category),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(Map<String, dynamic> category) {
    final TextEditingController budgetController =
        TextEditingController(text: category['budget'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${category['name']} Budget'),
          content: TextField(
            controller: budgetController,
            decoration: InputDecoration(labelText: 'Budget Amount'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                setState(() {
                  category['budget'] =
                      double.tryParse(budgetController.text) ?? 0.0;
                });

                // Save updated budgets to SharedPreferences
                final Map<String, dynamic> budgets = {
                  for (var cat in _categories) cat['name']: cat['budget']
                };
                prefs.setString('budgets', json.encode(budgets));

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Tracker')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildBudgetChart(),
              const SizedBox(height: 16),
              _buildBudgetList(),
            ],
          ),
        ),
      ),
    );
  }
}
