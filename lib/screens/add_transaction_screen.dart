import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:intl/intl.dart'; // For formatting dates

class AddTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? transaction;
  final int? transactionIndex;

  const AddTransactionScreen(
      {super.key, this.transaction, this.transactionIndex});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _selectedCategory = 'Food';
  String _transactionType = 'Income'; // Default transaction type
  String _paymentMethod = 'Cash'; // Default payment method
  final _amountController = TextEditingController();
  final List<String> _categories = [
    'Salary',
    'Food',
    'Investment',
    'Groceries',
    'Transport',
    'Utilities',
    'Entertainment',
    'Other'
  ];

  final Map<String, IconData> _categoryIcons = {
    'Salary': Icons.monetization_on,
    'Food': Icons.fastfood,
    'Investment': Icons.trending_up,
    'Groceries': Icons.shopping_cart,
    'Transport': Icons.directions_car,
    'Utilities': Icons.home,
    'Entertainment': Icons.movie,
    'Other': Icons.category,
  };

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      _transactionType = transaction['type'] ?? 'Income';
      _selectedCategory = transaction['category'] ?? 'Food';
      _paymentMethod = transaction['paymentMethod'] ?? 'Cash';
      _amountController.text = transaction['amount']?.toString() ?? '';
      _selectedDate =
          DateTime.tryParse(transaction['date'] ?? '') ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    final String amount = _amountController.text;

    if (amount.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final Map<String, dynamic> transaction = {
      'type': _transactionType,
      'category': _selectedCategory,
      'amount': double.tryParse(amount) ?? 0.0,
      'paymentMethod': _paymentMethod,
      'date': _selectedDate!.toIso8601String(),
    };

    final String? existingTransactions = prefs.getString('transactions');
    List<dynamic> transactions =
        existingTransactions != null ? json.decode(existingTransactions) : [];

    if (widget.transactionIndex != null) {
      transactions[widget.transactionIndex!] = transaction;
    } else {
      transactions.add(transaction);
    }

    await prefs.setString('transactions', json.encode(transactions));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction saved successfully!')),
    );

    Navigator.pop(context);
  }

  void _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction != null
            ? 'Edit Transaction'
            : 'Add Transaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transaction Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: const Text('Income'),
                      value: 'Income',
                      groupValue: _transactionType,
                      onChanged: (value) {
                        setState(() {
                          _transactionType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: const Text('Expense'),
                      value: 'Expense',
                      groupValue: _transactionType,
                      onChanged: (value) {
                        setState(() {
                          _transactionType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(_categoryIcons[category]),
                        const SizedBox(width: 10),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Amount',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
                items: ['Cash', 'Card', 'Online']
                    .map((method) => DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        ))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Payment Method'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No date selected'
                          : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveTransaction,
                child: Text(widget.transaction != null
                    ? 'Save Changes'
                    : 'Save Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help'),
          content: const Text(
            'To add or edit a transaction, fill in all fields, pick a date, and click "Save Transaction".',
            textAlign: TextAlign.center,
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
  }
}
