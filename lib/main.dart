import 'package:flutter/material.dart';
import 'splashscreen.dart'; // Import splash screen

void main() {
  runApp(const BukidNetTVApp());
}

class BukidNetTVApp extends StatelessWidget {
  const BukidNetTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Start with Splash Screen
    );
  }
}
