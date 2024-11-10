import 'package:flutter/material.dart';
import 'quiz_page.dart';
import '../services/api_service.dart';

class StagingArea extends StatelessWidget {
  final dynamic test;

  const StagingArea({super.key, required this.test});

  Future<void> beginTest(BuildContext context) async {
    // Example userId, replace with the actual userId from your authentication system
    const userId = 1;
    final testId = test['id'];
    final response = await ApiService.beginTest(userId, testId);

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizPage(
            subject: test['subject'],
            topic: test['topic'],
            userId: userId,
            testId: testId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to begin test')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staging Area')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => beginTest(context),
          child: const Text('Begin Test'),
        ),
      ),
    );
  }
}
