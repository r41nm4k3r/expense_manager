import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your logo image here
            Image.asset(
              'assets/images/logo.png', // Update this with the correct path to your logo
              width: 100, // Adjust the width as needed
              height: 100, // Adjust the height as needed
            ),
            const SizedBox(height: 20),
            const Text(
              'Expense Manager', // Your app title
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Made by Nny', // Your app title
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(), // Loading indicator
          ],
        ),
      ),
    );
  }
}
