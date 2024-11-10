import 'package:flutter/material.dart';

class ScorePage extends StatelessWidget {
  final int score;

  const ScorePage({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Score')),
      body: Center(
        child: Text('Your score: $score'),
      ),
    );
  }
}
