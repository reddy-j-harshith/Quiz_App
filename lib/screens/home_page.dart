import 'package:flutter/material.dart';
import 'dart:convert';
import 'staging_area.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> futureTests;

  @override
  void initState() {
    super.initState();
    futureTests = fetchTests();
  }

  Future<List<dynamic>> fetchTests() async {
    final response = await ApiService.fetchTests();

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load tests');
    }
  }

  Future<void> _refreshTests() async {
    setState(() {
      futureTests = fetchTests();
    });
  }

  void _logout() async {
    await TokenService.clearTokens();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Tests'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTests,
        child: FutureBuilder<List<dynamic>>(
          future: futureTests,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final tests = snapshot.data!;
              return ListView.builder(
                itemCount: tests.length,
                itemBuilder: (context, index) {
                  final test = tests[index];
                  return ListTile(
                    title: Text('${test['subject']} - ${test['topic']}'),
                    enabled: test['active'],
                    onTap: test['active']
                        ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StagingArea(test: test),
                      ),
                    )
                        : null,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
