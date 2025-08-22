import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0f2027), // 深色蓝灰
            Color(0xFF203a43), // 蓝绿
            Color(0xFF2c5364), // 青蓝
          ],
        ),
      ),
      child: child,
    );
  }
}
