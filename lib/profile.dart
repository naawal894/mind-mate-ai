import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mc_project/container.dart';

class ProfilePage extends StatelessWidget {
  final String testName;

  const ProfilePage({super.key, required this.testName});

  // Function to handle Firebase Logout
  Future<void> _logout(BuildContext context) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
           leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 58, 0, 0)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
          title: const Text('Profile Page',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          backgroundColor: Color.fromARGB(255, 97, 0, 0),
        ),
        body: const Center(
          child: Text('User not logged in.', style: TextStyle(color:Colors.black,fontWeight: FontWeight.w900,fontSize: 24.0)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: const Color.fromARGB(255, 189, 79, 39),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color.fromARGB(255, 97, 0, 0)),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Users').doc(user.uid).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          Map<String, dynamic>? data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(child: Text('No data found.'));
          }

          String email = data['email'] ?? 'No email available';
          String firstName = data['firstName'] ?? 'No name';
          String lastName = data['lastName'] ?? '';
          String fullName = '$firstName $lastName';

          return SizedBox.expand(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  image: AssetImage("assets/profile.png"),
                  fit: BoxFit.fill,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    const SizedBox(height: 10),
                    // Center(
                    //   child: CircleAvatar(
                    //     radius: 60,
                    //     backgroundColor: const Color.fromARGB(255, 97, 0, 0),
                    //     child: CircleAvatar(
                    //       radius: 56,
                    //       backgroundColor: Colors.white,
                    //       child: Text(firstName[0].toUpperCase(),
                    //           style: const TextStyle(
                    //               fontSize: 50, 
                    //               fontWeight: FontWeight.bold, 
                    //               color: Color.fromARGB(255, 97, 0, 0))),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 25),
                    
                    // User Info Section (Cards Removed)
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.black),
                      title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      subtitle: const Text('Full Name', style: TextStyle(color: Colors.black54)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.black),
                      title: Text(email, style: const TextStyle(color: Colors.black)),
                      subtitle: const Text('Email Address', style: TextStyle(color: Colors.black54)),
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.black26),
                    ),

                    // Test Results Section
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, bottom: 10),
                      child: Text('Assessment History', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                    
                    // Dynamically build result lines (Cards Removed)
                    _buildResultRow(data, 'AnxietyTestScore', 'AnxietyDiagnosis', 'Anxiety Test'),
                    _buildResultRow(data, 'ADHDTestScore', 'ADHDDiagnosis', 'ADHD Test'),
                    _buildResultRow(data, 'DepressionTestScore', 'DepressionDiagnosis', 'Depression Test'),
                    _buildResultRow(data, 'EatingDisorderTestScore', 'EatingDisorderDiagnosis', 'Eating Disorder Test'),
                    _buildResultRow(data, 'StressTestScore', 'StressDiagnosis', 'Stress Test'),
                    
                    const SizedBox(height: 30),
                    

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper widget to build clean result rows without Cards
  Widget _buildResultRow(Map<String, dynamic> data, String scoreKey, String diagKey, String title) {
    int score = data[scoreKey] ?? 0;
    String diagnosis = data[diagKey] ?? '';

    if (score == 0 && diagnosis.isEmpty) return const SizedBox.shrink();

    return ListTile(
      leading: const Icon(Icons.analytics, color: Colors.purple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      subtitle: Text('Diagnosis: $diagnosis', style: const TextStyle(color: Colors.black87)),
      trailing: Text('Score: $score', 
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 16)),
    );
  }
}