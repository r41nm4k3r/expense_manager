import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

                    return ListTile(
                      title: Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Type: $type, Amount: \$${amount}'),
                      trailing: Text(
                        date,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    );
                  },
                ),
    );
  }
}
