import 'package:flutter/material.dart';

class EditTransactionScreen extends StatefulWidget {
  final dynamic transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late String _type;
  late String _category;
  late double _amount;
  late DateTime _date;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _type = widget.transaction['type'];
    _category = widget.transaction['category'];
    _amount = widget.transaction['amount']?.toDouble() ?? 0.0;
    _date = DateTime.parse(widget.transaction['date']);
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final updatedTransaction = {
        'type': _type,
        'category': _category,
        'amount': _amount,
        'date': _date.toIso8601String(),
      };

      Navigator.pop(context, updatedTransaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _type,
                decoration:
                    const InputDecoration(labelText: 'Type (Income/Expense)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a type';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _type = value;
                  });
                },
              ),
              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _category = value;
                  });
                },
              ),
              TextFormField(
                initialValue: _amount.toString(),
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _amount = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
              TextFormField(
                initialValue: _date.toLocal().toString().split(' ')[0],
                decoration: const InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _date = pickedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTransaction,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
