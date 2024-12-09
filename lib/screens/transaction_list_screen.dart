import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart'; // For CSV export
import 'package:path_provider/path_provider.dart'; // For file storage
import 'package:intl/intl.dart'; // For date formatting
import 'edit_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<dynamic> _transactions = [];
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

  Future<void> _exportToCSV() async {
    List<List<String>> csvData = [
      // Add headers
      ['Category', 'Type', 'Amount', 'Date'],
      // Add rows
      ..._transactions.map((transaction) => [
            transaction['category'] ?? 'Unknown',
            transaction['type'] ?? 'Unknown',
            transaction['amount']?.toString() ?? '0.00',
            transaction['date'] ?? 'N/A',
          ])
    ];

    String csvString = const ListToCsvConverter().convert(csvData);

    // Use getApplicationDocumentsDirectory instead of getExternalStorageDirectory
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/transactions.csv';

    // Write to file
    final file = File(filePath);
    await file.writeAsString(csvString);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Exported to $filePath'),
      duration: const Duration(seconds: 3),
    ));
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('transactions', json.encode(_transactions));
    }
  }

  void _deleteTransaction(int index) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
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

    if (confirmed == true) {
      setState(() {
        _transactions.removeAt(index);
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('transactions', json.encode(_transactions));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportToCSV,
          ),
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
                                  Text(
                                    category,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Type: $type, Amount: \$${amount}',
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    formattedDate,
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
    );
  }
}
