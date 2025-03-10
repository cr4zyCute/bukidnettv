import 'package:flutter/material.dart';
import 'view/mainScreen.dart'; // Import the main screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BukidNetTVScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change background color as needed
      body: Center(
        child: Image.asset(
          'assets/bukidNet.jpg', // Make sure this image exists
          width: 200, // Adjust the size as needed
        ),
      ),
    );
  }
}
