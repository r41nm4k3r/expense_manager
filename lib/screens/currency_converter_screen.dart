import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final TextEditingController amountController = TextEditingController();
  double conversionRate = 0.0;
  String convertedAmount = '';
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';

  // This function will fetch the conversion rate from an API.
  Future<void> fetchConversionRate() async {
    final url = 'https://api.exchangerate-api.com/v4/latest/$fromCurrency';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          conversionRate = data['rates'][toCurrency];
          double amount = double.tryParse(amountController.text) ?? 0.0;
          convertedAmount = (amount * conversionRate).toStringAsFixed(2);
        });
      } else {
        // Handle API error (e.g., bad response)
        print("Failed to fetch conversion rate.");
      }
    } catch (e) {
      // Handle network error or exceptions
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.currency_exchange,
              color: Colors.orange,
              size: 80,
            ),
            const SizedBox(height: 150),
            // Amount input
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // From Currency Dropdown
            DropdownButton<String>(
              value: fromCurrency,
              items: <String>['USD', 'EUR', 'GBP', 'INR']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  fromCurrency = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // To Currency Dropdown
            DropdownButton<String>(
              value: toCurrency,
              items: <String>['USD', 'EUR', 'GBP', 'INR']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  toCurrency = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Convert button
            ElevatedButton(
              onPressed: fetchConversionRate,
              child: const Text('Convert'),
            ),
            const SizedBox(height: 20),

            // Display the converted amount
            if (convertedAmount.isNotEmpty)
              Text(
                '${amountController.text} $fromCurrency = $convertedAmount $toCurrency',
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 16), // Add some space before the footer
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
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
          ],
        ),
      ),
    );
  }
}
