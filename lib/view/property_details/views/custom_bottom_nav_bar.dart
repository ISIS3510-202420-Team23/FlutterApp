import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatelessWidget {
  final String agentName;
  final String price;
  final VoidCallback onContactPressed;

  const CustomBottomNavbar({
    super.key,
    required this.agentName,
    required this.price,
    required this.onContactPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9EFD7), // Custom background color
      padding: const EdgeInsets.symmetric(
          vertical: 20.0, horizontal: 15.0), // Adjust padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage(
                    'lib/assets/pau.jpg'), // Add the correct asset or color
                radius: 25,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agentName,
                    style: const TextStyle(
                      fontFamily: 'League Spartan',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0C356A),
                    ),
                  ),
                  const Text(
                    'Property agent',
                    style: TextStyle(
                      fontFamily: 'League Spartan',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0C356A),
                    ),
                  ),
                  Text(
                    '\$$price',
                    style: const TextStyle(
                      fontFamily: 'League Spartan',
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: onContactPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C356A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text(
              'Contact',
              style: TextStyle(
                fontFamily: 'League Spartan',
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
