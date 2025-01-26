import 'package:flutter/material.dart';
import '../services/firebase_services.dart';
import '../screens/Homepage.dart'; // Import your HomePage

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseServices = FirebaseServices();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD1A055), // Top gradient color
              Color(0xFFF3C1A9), // Bottom gradient color
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo
                Image.asset(
                  'assets/EVENTO_logo.png', // Replace with your image path
                  height: 300,
                  width: 400,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),

                // Heading
                const Text(
                  "Let's Plan Your Next",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  "Event Together!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 36),

                // Divider Line
                Container(
                  color: Colors.black,
                  width: 400,
                  height: 4,
                ),
                const SizedBox(height: 24),

                // Google Sign-In Button
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await firebaseServices.signInWithGoogle();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login successful!')),
                      );

                      // Navigate to HomePage after successful login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    side: const BorderSide(color: Colors.black),
                  ),
                  icon: Image.asset(
                    'assets/google.jpg',
                    height: 20,
                    width: 20,
                  ),
                  label: const Text(
                    "Sign in with Google",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
