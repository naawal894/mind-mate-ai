import 'package:flutter/material.dart';
import 'deptest.dart';  // Make sure to import this file as well
import 'anxiety_test.dart';
import 'stress_test.dart';
import 'eating_disorder_test.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> tests = [
    {'name': 'Depression Test', 'route': '/test/depression'},
    {'name': 'Anxiety Test', 'route': '/test/anxiety'},
    {'name': 'Stress Test', 'route': '/test/stress'},
    {'name': 'Eating Disorder Test', 'route': '/test/eating'},
  ];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 58, 0, 0)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.purple.shade100,
        title: const Text(
          'Loud Minds',
          style: TextStyle(
            color: Color.fromARGB(255, 58, 0, 0),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Wrapped the body in DecoratedBox as requested
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/chatbg6.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // General Information Section
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Mental Health Test',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 58, 0, 0),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Mental health is essential for our overall well-being. Here, you can take various tests to assess your mental health condition. Below are some of the tests you can take:',
                      style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Mental Health Tests Section
              Expanded(
                child: ListView.builder(
                  itemCount: tests.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.purple.shade100,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(
                          tests[index]['name']!,
                          style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, tests[index]['route']!);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
    routes: {
      '/test/depression': (context) => const DepressionTestScreen(),
      '/test/anxiety': (context) => const AnxietyTestScreen(),
      '/test/stress': (context) => const StressTestScreen(),
      '/test/eating': (context) => const EatingDisorderTestScreen(),
    },
  ));
}