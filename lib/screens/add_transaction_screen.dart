import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding/decoding

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // Default values
  String _selectedCategory = 'Food';
  String _transactionType = 'Expense'; // Default transaction type
  final _amountController = TextEditingController();
  final List<String> _categories = ['Food', 'Transport', 'Salary', 'Other'];

  @override
  void dispose() {
    _amountController.dispose(); // Dispose the controller to avoid memory leaks
    super.dispose();
  }

  void _saveTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    final String amount = _amountController.text;

    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    // New transaction object
    final Map<String, dynamic> transaction = {
      'type': _transactionType,
      'category': _selectedCategory,
      'amount': double.parse(amount),
      'date': DateTime.now().toString(),
    };

    // Fetch existing transactions
    final String? existingTransactions = prefs.getString('transactions');
    List<dynamic> transactions =
        existingTransactions != null ? json.decode(existingTransactions) : [];

    // Add new transaction and save back
    transactions.add(transaction);
    await prefs.setString('transactions', json.encode(transactions));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction added successfully!')),
    );

    Navigator.pop(context); // Go back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
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
                  child: Text(category),
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

            // Save Button
            ElevatedButton(
              onPressed: _saveTransaction,
              child: const Text('Save Transaction'),
            ),
          ],
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
            'Here you can add either an Income or Expense transaction. Select the transaction type, choose a category, '
            'enter the amount, and then click "Save Transaction". Your transaction will be saved for future tracking.',
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
