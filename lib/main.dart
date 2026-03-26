import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mc_project/container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mc_project/deptest.dart';
import 'package:mc_project/home.dart';
import 'package:mc_project/login.dart';
import 'package:mc_project/profile.dart';
import 'package:mc_project/reg.dart';
import 'anxiety_test.dart';
import 'stress_test.dart';
import 'eating_disorder_test.dart';
import 'splash_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Future<FirebaseApp> initialization = Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDl9AsT8DjQXd-JWgibn2Z8SxvCwaiFHoE",
      authDomain: "mc-project-f5f8b.firebaseapp.com",
      projectId: "mc-project-f5f8b",
      storageBucket: "mc-project-f5f8b.firebasestorage.app",
      messagingSenderId: "708455995412",
      appId: "1:708455995412:web:e5320f10e2ae9d3d446f01",
      measurementId: "G-PQX4RHWM6F"
    ),
  );

  runApp(MyApp(initialization: initialization));
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> initialization;

  const MyApp({super.key, required this.initialization});

  @override
  Widget build(BuildContext context) {
    // We no longer need the checkIfUserIsLoggedIn function here.

    return FutureBuilder(
      // 1. Check if Firebase is initialized
      future: initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading screen while Firebase initializes
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          // Show an error screen if initialization fails
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: Text("Error initializing Firebase!")),
            ),
          );
        }

        // 2. Firebase is ready, now check the user's login status
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Your App',
          // 💡 New Home Widget: StreamBuilder listens for Auth state changes
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              if (authSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
              );
       }

    // Decide destination first
       final Widget destination = (authSnapshot.hasData && authSnapshot.data != null)
        ? const ContainerScreen()
        : const LoginScreen();

    // Show splash BEFORE navigating
      return SplashScreen(nextScreen: destination);
  },
),

          
          // Your existing named routes remain here:
          routes: {
            '/login': (context) => const LoginScreen(key: Key("LoginScreen")),
            '/home': (context) => HomeScreen(key: const Key("HomeScreen")),
            '/registration': (context) =>
                const RegistrationScreen(key: Key("RegistrationScreen")),
            '/test/depression': (context) =>
                const DepressionTestScreen(key: Key("DepressionTestScreen")),
            '/profile': (context) => ProfilePage(testName: ''),
            '/test/anxiety': (context) =>
                const AnxietyTestScreen(key: Key("AnxietyTestScreen")),
          },
          theme: ThemeData.dark(),
        );
      },
    );
  }
}