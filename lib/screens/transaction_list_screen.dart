import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'edit_transaction_screen.dart'; // Import the new EditTransactionScreen
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<dynamic> _transactions = [];
  Set<int> _selectedTransactions = {}; // Track selected transactions
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsString = prefs.getString('transactions');

    setState(() {
      _transactions =
          transactionsString != null ? json.decode(transactionsString) : [];
      _isLoading = false;
    });
  }

  void _editTransaction(int index) async {
    final transaction = _transactions[index];
    final updatedTransaction = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    );

    if (updatedTransaction != null) {
      setState(() {
        _transactions[index] = updatedTransaction;
      });

      // Save the updated transaction to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('transactions', json.encode(_transactions));
    }
  }

  void _deleteTransaction(int index) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
            'Are you sure you want to delete this transaction? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _transactions.removeAt(index);
      });

      // Update SharedPreferences after deletion
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('transactions', json.encode(_transactions));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Transaction deleted'),
      ));
    }
  }

  void _deleteSelectedTransactions() async {
    if (_selectedTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No transactions selected'),
      ));
      return;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
            'Are you sure you want to delete the selected transactions? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _transactions = _transactions
            .asMap()
            .entries
            .where((entry) => !_selectedTransactions.contains(entry.key))
            .map((entry) => entry.value)
            .toList();
        _selectedTransactions.clear();
      });

      // Update SharedPreferences after deletion
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('transactions', json.encode(_transactions));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selected transactions deleted'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction List'),
        actions: [
          if (_selectedTransactions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedTransactions,
            ),
        ],
      ),
      body: Column(
        children: [
          // Transaction list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? const Center(child: Text('No transactions added yet!'))
                    : ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _transactions[index];

                          // Use null-aware operators to ensure values are valid
                          final category = transaction['category'] ?? 'Unknown';
                          final type = transaction['type'] ?? 'Unknown';
                          final amount =
                              transaction['amount']?.toString() ?? '0.00';
                          final date = transaction['date'] ?? 'N/A';

                          // Format the date using intl package
                          final DateTime transactionDate = DateTime.parse(date);
                          final String formattedDate =
                              DateFormat('dd-MM-yyyy').format(transactionDate);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16),
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value:
                                        _selectedTransactions.contains(index),
                                    onChanged: (isSelected) {
                                      setState(() {
                                        if (isSelected == true) {
                                          _selectedTransactions.add(index);
                                        } else {
                                          _selectedTransactions.remove(index);
                                        }
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Type: $type, Amount: \$${amount}',
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formattedDate, // Display formatted date
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () =>
                                            _editTransaction(index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () =>
                                            _deleteTransaction(index),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          // Footer section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
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
            ),
          ),
        ],
      ),
    );
  }
}
