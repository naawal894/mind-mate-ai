import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mc_project/reg.dart'; // Ensure this path is correct // Add this import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _obscureText = true;
  bool rememberMe = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final AuthService authService = AuthService();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.easeInOut,
      ),
    );

    // Start initial animations
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shakeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _forgotPassword() {
    // (Your existing _forgotPassword function logic remains the same)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController resetEmailController = TextEditingController();

        return AlertDialog(
          title: const Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email address to reset your password.'),
              TextField(
                controller: resetEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();

                if (email.isNotEmpty) {
                  try {
                    await authService.sendPasswordResetEmail(email);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent!'),
                      ),
                    );
                  } on FirebaseAuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.message}'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid email address."),
                    ),
                  );
                }

                Navigator.pop(context);
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  // 💡 THE CRITICAL UPDATE IS HERE 💡
  loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Attempt to sign in
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. SUCCESS: Show a toast and save UID
      Fluttertoast.showToast(msg: "Login Successful");

      // Save User ID (keep this if you need it later)
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        "userID",
        credential.user?.uid ?? " ",
      );
      
      // *** REMOVED: await prefs.setBool('isLoggedIn', true); ***
      // *** REMOVED: Navigator.pushAndRemoveUntil(...) ***
      // The StreamBuilder in main.dart will now automatically handle navigation!

    } on FirebaseAuthException catch (e) {
      // 3. FAILURE: Show the specific Firebase error
      String message;
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Invalid email or password.';
      } else {
        message = 'Login failed: ${e.message}';
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // (Your existing build method remains the same)
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/Login.jpg',
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.5),
              colorBlendMode: BlendMode.modulate,
            ),
          ),
          // Login Form
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _fadeAnimation,
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Enter Email",
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: TextField(
                        controller: passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: "Enter Password",
                          labelStyle: const TextStyle(color: Colors.black),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value!;
                            });
                          },
                        ),
                        const Text("Remember Me"),
                        const Spacer(),
                        GestureDetector(
                          onTap: _forgotPassword,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        loginUser(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                      },
                      child: const Text("Login"),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text("Don't have an account?"),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}