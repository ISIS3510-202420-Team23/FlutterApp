import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';  // Import for responsive sizes
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
            crossAxisAlignment: CrossAxisAlignment.center, // Centers horizontally
            children: [
              Center( // Wrap to center horizontally and vertically
                child: Image.asset('lib/assets/andlet.png', height: 250.h), // Responsive height
              ),
              SizedBox(height: 5.h), // Responsive spacing
              Text(
                'Andlet',
                style: TextStyle(
                  fontFamily: 'League Spartan',
                  fontSize: 60.sp, // Responsive font size
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0C356A),
                ),
              ),
              SizedBox(height: 10.h), // Responsive spacing
              Text(
                'HOUSING CONNECT APP',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15.sp, // Responsive font size
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0C356A),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 70.h, // Responsive positioning
            right: 40.w, // Responsive positioning
            child: Container(
              height: 60.h,  // Responsive height
              width: 60.w,   // Responsive width
              decoration: const BoxDecoration(
                color: Color(0xFF0C356A), // Circle background color (dark blue)
                shape: BoxShape.circle, // Makes it circular
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_forward, color: Colors.white, size: 30.sp), // Responsive icon size
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
            bottom: 70.h, // Responsive positioning
            left: 40.w, // Responsive positioning
            child: Row(
              children: [
                Container(
                  width: 10.w, // Responsive width
                  height: 10.h, // Responsive height
                  decoration: const BoxDecoration(
                    color: Color(0xFF0C356A),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.w), // Responsive spacing
                Container(
                  width: 10.w,
                  height: 10.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9A826),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.w), // Responsive spacing
                Container(
                  width: 10.w,
                  height: 10.h,
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
