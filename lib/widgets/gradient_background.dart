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
            Color(0xFF1a0033), // 深紫黑
            Color(0xFF3a0ca3), // 紫蓝
            Color(0xFF7209b7), // 亮紫
            // Color(0xFF120022), // 更深的紫黑
            // Color(0xFF2a0880), // 更深的紫蓝
            // Color(0xFF5a078f), // 更暗的亮紫
          ],
        ),
      ),
      child: child,
    );
  }
}
