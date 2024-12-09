import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'edit_transaction_screen.dart'; // Import the new EditTransactionScreen

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
    setState(() {
      _transactions.removeAt(index);
    });

    // Update SharedPreferences after deletion
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transactions', json.encode(_transactions));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction List')),
      body: _isLoading
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
                    final amount = transaction['amount']?.toString() ?? '0.00';
                    final date = transaction['date'] ?? 'N/A';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          category,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Type: $type, Amount: \$${amount}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editTransaction(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteTransaction(index),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          print('Tapped on transaction: $transaction');
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
