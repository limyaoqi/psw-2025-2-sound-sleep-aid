import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Text(
            "Welcome to My Flutter App",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
