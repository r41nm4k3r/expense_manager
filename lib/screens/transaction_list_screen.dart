import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // For date formatting
import 'package:path_provider/path_provider.dart'; // For file access
import 'package:csv/csv.dart'; // For CSV export
import 'dart:io'; // For File operations
import 'add_transaction_screen.dart'; // Import the AddTransactionScreen

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  final Set<int> _selectedTransactions = <int>{};
  bool _isSelecting = false; // Track if we are in selection mode

  // Define a map for category icons
  final Map<String, IconData> _categoryIcons = {
    'Salary': Icons.monetization_on,
    'Food': Icons.fastfood,
    'Investment': Icons.trending_up,
    'Groceries': Icons.shopping_cart,
    'Transport': Icons.directions_car,
    'Utilities': Icons.home,
    'Entertainment': Icons.movie,
    'Other': Icons.request_page,
  };

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

  // Toggle selection mode
  void _toggleSelectionMode() {
    setState(() {
      _isSelecting = !_isSelecting;
      if (!_isSelecting) {
        _selectedTransactions
            .clear(); // Clear selection when exiting selection mode
      }
    });
  }

  // Toggle selection of a transaction
  void _toggleSelection(int index) {
    setState(() {
      if (_selectedTransactions.contains(index)) {
        _selectedTransactions.remove(index);
      } else {
        _selectedTransactions.add(index);
      }
    });
  }

  Future<void> _editTransaction(int index) async {
    final transaction = _transactions[index];

    // Navigate to AddTransactionScreen with pre-filled details
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          transaction: transaction, // Pass the selected transaction
          transactionIndex: index,
        ),
      ),
    );

    // If an updated transaction is returned, update the list
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _transactions[index] = result; // Update transaction in the list
      });

      // Save the updated transactions to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('transactions', json.encode(_transactions));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction updated successfully!')),
      );
    }
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
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _transactions.removeAt(index);
      });

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('transactions', json.encode(_transactions));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted')),
      );
    }
  }

  // Bulk delete function
  void _bulkDeleteTransactions() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Bulk Delete'),
        content: const Text(
            'Are you sure you want to delete the selected transactions? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _transactions.removeWhere((transaction) =>
            _selectedTransactions.contains(_transactions.indexOf(transaction)));
        _selectedTransactions.clear();
      });

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('transactions', json.encode(_transactions));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected transactions deleted')),
      );
    }
  }

  Future<void> _exportTransactionsToCSV() async {
    if (_transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
      return;
    }

    List<List<String>> rows = [
      [
        "Category",
        "Type",
        "Amount",
        "Date",
        "Payment Method",
        "Description"
      ], // Added Description column
    ];

    for (var transaction in _transactions) {
      rows.add([
        transaction['category']?.toString() ?? '',
        transaction['type']?.toString() ?? '',
        transaction['amount']?.toString() ?? '0.00',
        transaction['date']?.toString() ?? 'N/A',
        transaction['paymentMethod']?.toString() ?? 'Unknown',
        transaction['description']?.toString() ?? '', // Added Description field
      ]);
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/transactions.csv');
    final csv = const ListToCsvConverter().convert(rows);

    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Transactions exported to $path/transactions.csv')),
    );
  }

  void _showTransactionDetails(int index) {
    final transaction = _transactions[index];
    final category = transaction['category'] ?? 'Unknown';
    final type = transaction['type'] ?? 'Unknown';
    final amount = transaction['amount']?.toString() ?? '0.00';
    final date = transaction['date'] ?? 'N/A';
    final description = transaction['description'] ?? 'No description';

    final DateTime transactionDate = DateTime.parse(date);
    final String formattedDate =
        DateFormat('dd-MM-yyyy').format(transactionDate);

    final icon = _categoryIcons[category] ?? Icons.category;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Transaction Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Type: $type'),
              Text('Amount: \$$amount'),
              Text('Date: $formattedDate'),
              Text(
                  'Payment Method: ${transaction['paymentMethod'] ?? 'Unknown'}'),
              Text('Description: $description'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () => _editTransaction(index),
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () => _deleteTransaction(index),
              child: const Text('Delete'),
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
        title: const Text('Transaction List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadTransactions(); // Manually reload the transactions
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportTransactionsToCSV,
          ),
          // Bulk delete button
          if (_isSelecting) ...[
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _selectedTransactions.isEmpty
                  ? null
                  : _bulkDeleteTransactions,
            ),
            IconButton(
              icon: const Icon(Icons.check_box_outline_blank),
              onPressed: () {
                setState(() {
                  _selectedTransactions.clear();
                });
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _toggleSelectionMode,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? const Center(child: Text('No transactions added yet!'))
                    : ListView.builder(
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _transactions[index];

                          return GestureDetector(
                            onTap: _isSelecting
                                ? () => _toggleSelection(index)
                                : () => _showTransactionDetails(index),
                            onLongPress:
                                _toggleSelectionMode, // Enter selection mode on long press
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 16),
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    if (_isSelecting)
                                      Checkbox(
                                        value: _selectedTransactions
                                            .contains(index),
                                        onChanged: (bool? value) {
                                          _toggleSelection(index);
                                        },
                                      ),
                                    Icon(
                                      _categoryIcons[transaction['category']] ??
                                          Icons.category,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${transaction['category']} - ${transaction['type']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('\$${transaction['amount']}'),
                                          Text(
                                            DateFormat('dd-MM-yyyy').format(
                                              DateTime.parse(
                                                  transaction['date']),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Display description here
                                          Text(
                                            transaction['description'] ??
                                                'No description',
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How to edit transactions'),
          content: const Text(
            'To edit a transaction, press on the entry you want to modify, hit edit, make the changes you like and press "Save Changes". After closing the popup window hit refresh on the upper right of the screen in order for the changes to appear.',
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
