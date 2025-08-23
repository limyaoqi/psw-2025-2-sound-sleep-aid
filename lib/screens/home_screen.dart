import 'package:flutter/material.dart';

import '../widgets/gradient_background.dart';
import '../widgets/player_card.dart';
import '../widgets/bottom_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: const [
              SizedBox(height: 24),
              Expanded(child: Center(child: PlayerCard())),
              Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: BottomMenu(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
