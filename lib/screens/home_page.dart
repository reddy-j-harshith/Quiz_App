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
                padding: const EdgeInsets.all(16.0),
                itemCount: tests.length,
                itemBuilder: (context, index) {
                  final test = tests[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${test['subject']} - ${test['topic']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            test['description'] ?? 'No description available',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: test['active']
                                  ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StagingArea(test: test),
                                  ),
                                );
                              }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: test['active'] ? Colors.purple : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: test['active'] ? 2 : 0,
                              ),
                              child: Text(
                                'Attempt',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0, // Highlight "Home" as the current page
        onTap: (index) {
          if (index == 1) {
            // Navigate to the Profile page
          }
        },
      ),
    );
  }
}