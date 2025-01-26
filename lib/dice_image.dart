import 'package:flutter/material.dart';

class DiceImage extends StatelessWidget {
  final int diceValue;

  const DiceImage({super.key, required this.diceValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/dice$diceValue.png', // Display corresponding dice image based on the dice value
          width: 50,
          height: 50,
        ),
        const SizedBox(height: 5),
        Text(
          '$diceValue',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
