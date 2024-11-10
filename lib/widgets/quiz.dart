import 'package:flutter/material.dart';

class Quiz extends StatelessWidget {
  final dynamic question;
  final Function(String) onSubmitAnswer;

  const Quiz({super.key, required this.question, required this.onSubmitAnswer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            question['question_name'],
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20.0),
          ...['option_1', 'option_2', 'option_3', 'option_4'].map((option) {
            return ElevatedButton(
              onPressed: () => onSubmitAnswer(option),
              child: Text(question[option]),
            );
          }).toList(),
        ],
      ),
    );
  }
}
