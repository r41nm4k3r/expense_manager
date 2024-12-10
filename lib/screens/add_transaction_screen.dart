import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding

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
  final List<String> _categories = ['Food', 'Transport', 'Salary', 'Other'];

  // Map of category names to icons
  final Map<String, IconData> _categoryIcons = {
    'Food': Icons.fastfood,
    'Transport': Icons.directions_car,
    'Salary': Icons.monetization_on,
    'Other': Icons.category,
  };

  DateTime? _selectedDate; // Store the selected date

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      // Initialize fields with existing transaction data if available
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
    _amountController.dispose(); // Dispose the controller to avoid memory leaks
    super.dispose();
  }

  void _saveTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    final String amount = _amountController.text;

    if (amount.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all details')),
      );
      return;
    }

    final Map<String, dynamic> transaction = {
      'type': _transactionType,
      'category': _selectedCategory,
      'amount': double.parse(amount),
      'paymentMethod': _paymentMethod,
      'date': _selectedDate!.toIso8601String(), // Save selected date
    };

    // Fetch existing transactions
    final String? existingTransactions = prefs.getString('transactions');
    List<dynamic> transactions =
        existingTransactions != null ? json.decode(existingTransactions) : [];

    // If editing, replace the existing transaction
    if (widget.transactionIndex != null) {
      transactions[widget.transactionIndex!] = transaction;
    } else {
      // Add new transaction
      transactions.add(transaction);
    }

    await prefs.setString('transactions', json.encode(transactions));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction saved successfully!')),
    );

    Navigator.pop(context); // Go back after saving
  }

  void _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
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
            onPressed: () {
              _showHelpDialog(); // Show help dialog
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type
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

              // Category Dropdown
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
                        Icon(_categoryIcons[category]), // Display icon
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

              // Amount Input
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

              // Payment Method Dropdown
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                onChanged: (String? value) {
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

              // Date Picker
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
                          : 'Selected Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Save Button
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
            'Here you can add or edit a transaction. Select the transaction type, choose a category, enter the amount, pick a date, and then click "Save Transaction". Your transaction will be saved for future tracking.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the help dialog
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
