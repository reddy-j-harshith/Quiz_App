import 'dart:convert';

import 'package:flutter/material.dart';
import 'score_page.dart';
import '../services/api_service.dart';
import '../widgets/quiz.dart';

class QuizPage extends StatefulWidget {
  final String subject;
  final String topic;
  final int userId;
  final int testId;

  const QuizPage({super.key,
    required this.subject,
    required this.topic,
    required this.userId,
    required this.testId,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final response = await ApiService.fetchQuestions(widget.subject, widget.topic);

    if (response.statusCode == 200) {
      setState(() {
        questions = jsonDecode(response.body).take(10).toList();
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load questions')),
      );
    }
  }

  void submitAnswer(String selectedOption) {
    if (selectedOption == questions[currentQuestionIndex]['correct_option']) {
      score++;
    }
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      endTest();
    }
  }

  Future<void> endTest() async {
    final response = await ApiService.endTest(widget.userId, widget.testId);

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScorePage(score: score),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to end test')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Quiz(
        question: questions[currentQuestionIndex],
        onSubmitAnswer: submitAnswer,
      ),
    );
  }
}
