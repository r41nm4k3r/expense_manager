import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  double _predictedExpense = 0.0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Income', 'amount': 0.0, 'color': Colors.green},
    {'name': 'Expense', 'amount': 0.0, 'color': Colors.red},
  ];

  final List<Map<String, dynamic>> _monthlyExpenses = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() async {
    print("Monthly Expenses: $_monthlyExpenses");
    print("Predicted Expense: $_predictedExpense");
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsString = prefs.getString('transactions');
    List<dynamic> transactions =
        transactionsString != null ? json.decode(transactionsString) : [];

    double income = 0.0;
    double expense = 0.0;
    Map<String, double> monthlyExpenseMap = {};

    for (var transaction in transactions) {
      if (transaction['type'] == 'Income') {
        income += transaction['amount'];
      } else if (transaction['type'] == 'Expense') {
        expense += transaction['amount'];
        final DateTime date = DateTime.parse(transaction['date']);
        final String monthKey = "${date.year}-${date.month}";
        monthlyExpenseMap[monthKey] =
            (monthlyExpenseMap[monthKey] ?? 0) + transaction['amount'];
      }
    }

    setState(() {
      _totalIncome = income;
      _totalExpense = expense;
      _categories[0]['amount'] = income;
      _categories[1]['amount'] = expense;
      _monthlyExpenses.clear();
      _monthlyExpenses.addAll(monthlyExpenseMap.entries
          .map((entry) => {'month': entry.key, 'amount': entry.value})
          .toList());
      _predictedExpense = _calculatePrediction();
    });
  }

  double _calculatePrediction() {
    if (_monthlyExpenses.isEmpty) return 0.0;

    final List<double> expenses = [];
    final List<int> months = [];

    for (int i = 0; i < _monthlyExpenses.length; i++) {
      expenses.add(_monthlyExpenses[i]['amount']);
      months.add(i);
    }

    // Perform simple linear regression
    double sumX = months.reduce((a, b) => a + b).toDouble();
    double sumY = expenses.reduce((a, b) => a + b);
    double sumXY = 0.0;
    double sumX2 = 0.0;

    for (int i = 0; i < months.length; i++) {
      sumXY += months[i] * expenses[i];
      sumX2 += months[i] * months[i];
    }

    double slope = (months.length * sumXY - sumX * sumY) /
        (months.length * sumX2 - sumX * sumX);
    double intercept = (sumY - slope * sumX) / months.length;

    // Predict for the next month
    return slope * months.length + intercept;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildIncomeVsExpenseChart(),
              const SizedBox(height: 16),
              _buildExpenseBreakdownChart(),
              const SizedBox(height: 16),
              _buildMonthlyExpenseTrends(),
              const SizedBox(height: 16),
              _buildPredictedExpense(),
              const SizedBox(height: 32),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Made with ',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Icon(
                      Icons.flutter_dash,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const Text(
                      ' and ',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictedExpense() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Predicted Expense for Next Month',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_predictedExpense.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeVsExpenseChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 200, // Explicit height constraint
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: _categories[0]['color'],
                      value: _totalIncome,
                      title:
                          '${(_totalIncome / (_totalIncome + _totalExpense) * 100).toStringAsFixed(1)}%',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: _categories[1]['color'],
                      value: _totalExpense,
                      title:
                          '${(_totalExpense / (_totalIncome + _totalExpense) * 100).toStringAsFixed(1)}%',
                      radius: 50,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Income vs Expense',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        color: category['color'],
                      ),
                      const SizedBox(width: 4),
                      Text(category['name']),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseBreakdownChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 200, // Explicit height constraint
              child: PieChart(
                PieChartData(
                  sections: _monthlyExpenses.map((entry) {
                    final Random random = Random();
                    final color = Color.fromARGB(
                      255,
                      random.nextInt(256),
                      random.nextInt(256),
                      random.nextInt(256),
                    );
                    entry['color'] = color; // Add color for legend
                    return PieChartSectionData(
                      color: color,
                      value: entry['amount'],
                      title: '${entry['amount'].toStringAsFixed(1)}',
                      radius: 50,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Expense Breakdown by Month',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _monthlyExpenses.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: entry['color'],
                    ),
                    const SizedBox(width: 4),
                    Text(entry['month']),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyExpenseTrends() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Expense Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200, // Explicit height constraint
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(
                    border: const Border(
                      left: BorderSide(),
                      bottom: BorderSide(),
                    ),
                  ),
                  titlesData: FlTitlesData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _monthlyExpenses
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value['amount'],
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _monthlyExpenses.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: Colors.blue, // Consistent color for trends
                    ),
                    const SizedBox(width: 4),
                    Text(entry['month']),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
