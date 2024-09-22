import 'package:flutter/material.dart';
import '../auth/views/login_view.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB5D5FF), // Light blue background
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,  // Centers horizontally
            children: [
              Center(  // Wrap to center horizontally and vertically
                child: Image.asset('lib/assets/andlet.png', height: 250),
              ),
              const SizedBox(height: 5),
              const Text(
                'Andlet',
                style: TextStyle(
                  fontFamily: 'League Spartan',
                  fontSize: 60,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0C356A),
                ),
              ),
              const SizedBox(height: 0),
              const Text(
                'HOUSING CONNECT APP',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0C356A),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 70,
            right: 40,
            child: Container(
              height: 60,
              width: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF0C356A), // Circle background color (dark blue)
                shape: BoxShape.circle,   // Makes it circular
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                iconSize: 30,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                  );
                },
              ),
            ),
          ),
          // Align the dots at the left-bottom side
          Positioned(
            bottom: 70,
            left: 40,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0C356A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9A826),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9A826),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
