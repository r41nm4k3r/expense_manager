import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
import 'package:path_provider/path_provider.dart'; // Import path_provider for file access
import 'package:csv/csv.dart'; // Import CSV package
import 'dart:io'; // For File operations

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  Set<int> _selectedTransactions = Set<int>();

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
    // Handle editing transaction (not shown in this code for brevity)
  }

  void _deleteTransaction(int index) async {
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete Selected'),
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
        // Fix the error by checking for the index in the selected transactions set
        _transactions.removeWhere((transaction) =>
            _selectedTransactions.contains(_transactions.indexOf(transaction)));
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

  Future<void> _exportTransactionsToCSV() async {
    if (_transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
      return;
    }

    // Define the header for the CSV
    List<List<String>> rows = [
      ["Category", "Type", "Amount", "Date"], // CSV header
    ];

    // Map each transaction to a list of strings and add it to rows
    for (var transaction in _transactions) {
      rows.add([
        transaction['category']?.toString() ?? '',
        transaction['type']?.toString() ?? '',
        transaction['amount']?.toString() ?? '0.00',
        transaction['date']?.toString() ?? 'N/A',
      ]);
    }

    // Get the app's document directory
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/transactions.csv');
    final csv = const ListToCsvConverter().convert(rows);

    // Write the CSV to a file
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Transactions exported to $path/transactions.csv')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportTransactionsToCSV, // Export to CSV button
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

                          final category = transaction['category'] ?? 'Unknown';
                          final type = transaction['type'] ?? 'Unknown';
                          final amount =
                              transaction['amount']?.toString() ?? '0.00';
                          final date = transaction['date'] ?? 'N/A';

                          final DateTime transactionDate = DateTime.parse(date);
                          final String formattedDate =
                              DateFormat('dd-MM-yyyy').format(transactionDate);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16),
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _selectedTransactions
                                            .contains(index),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value != null && value) {
                                              _selectedTransactions.add(index);
                                            } else {
                                              _selectedTransactions
                                                  .remove(index);
                                            }
                                          });
                                        },
                                      ),
                                      Text(
                                        category,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text('Type: $type, Amount: \$${amount}'),
                                  SizedBox(height: 4),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                  Text(
                                    'Payment Method: ${transaction['paymentMethod'] ?? 'Unknown'}',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                  SizedBox(height: 4),
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
          ),
        ],
      ),
      floatingActionButton: _selectedTransactions.isNotEmpty
          ? FloatingActionButton(
              onPressed: _deleteSelectedTransactions, // Bulk delete button
              child: const Icon(Icons.delete),
            )
          : null,
    );
  }
}
