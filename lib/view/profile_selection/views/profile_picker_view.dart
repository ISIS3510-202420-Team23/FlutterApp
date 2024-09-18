import 'package:flutter/material.dart';
import 'package:andlet/view/explore/views/explore_view.dart';

class ProfilePickerView extends StatelessWidget {
  const ProfilePickerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB5D5FF), // Light blue background
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Add padding around the content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Align text to the center
          children: [
            const SizedBox(height: 60), // Add some space from the top
            const Align(
              alignment: Alignment.centerLeft, // Keep "Let's start" aligned left
              child: Text(
                "Let's start!\nFirst...",
                style: TextStyle(
                  fontFamily: 'League Spartan',
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0C356A),
                ),
              ),
            ),
            const SizedBox(height: 150), // Add some space before the buttons
            const Center(
              child: Text(
                "What are you looking for?",
                textAlign: TextAlign.center, // Center the text horizontally
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  color: Color(0xFF0C356A),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ExploreView()), // Navigate to ExploreView
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB900),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'I want to rent a place!',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the "List my place" flow
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C356A),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'I want to list my place!',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(), // Push everything to the top
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0C356A),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
