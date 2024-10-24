import 'package:andlet/view/explore/views/explore_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:andlet/view_models/user_view_model.dart'; // Import UserViewModel
import 'package:andlet/models/entities/user.dart'; // Import User model
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added for responsiveness

class ProfilePickerView extends StatelessWidget {
  final String displayName; // Google displayName
  final String userEmail; // Google email
  final String photoUrl; // Google photoUrl

  const ProfilePickerView({
    super.key,
    required this.displayName,
    required this.userEmail,
    required this.photoUrl,
  });

  /// Save the user's selected profile type (tenant or landlord) locally.
  Future<void> _setUserProfileType(String profileType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileType', profileType);  // Save profile type to local storage
  }

  /// Use UserViewModel to post user data to Firestore and navigate.
  Future<void> _navigateAndSaveUser(BuildContext context, String profileType) async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    // Save the profile type locally
    await _setUserProfileType(profileType);

    // Create a new User object based on the selected profile type
    final newUser = User(
      email: userEmail,
      name: displayName,
      phone: 0, // Replace with real phone data if available
      photo: photoUrl,
      is_andes: true,  // Sample data, adjust accordingly
      type_user: profileType,
      favorite_offers: [],  // Default as an empty list for new users
    );

    // Add user to Firestore via the ViewModel
    await userViewModel.addUser(newUser);

    // Create the user_views document if it doesn't already exist
    await userViewModel.createUserViewsDocumentIfNotExists(userEmail);

    // Navigate to ExploreView after saving user data and creating user_views doc
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ExploreView(
            displayName: displayName, // Pass the Google displayName
            photoUrl: photoUrl, // Pass the Google photoUrl
            userEmail: userEmail, // Pass the Google email
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB5D5FF), // Light blue background
      body: Padding(
        padding: EdgeInsets.all(30.w), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Align text to the center
          children: [
            SizedBox(height: 40.h), // Responsive height
            Align(
              alignment: Alignment.centerLeft, // Keep "Let's start" aligned left
              child: Text(
                "Let's start!\nFirst...",
                style: TextStyle(
                  fontFamily: 'League Spartan',
                  fontSize: 40.sp, // Responsive font size
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0C356A),
                ),
              ),
            ),
            SizedBox(height: 150.h), // Responsive height before the buttons
            Center(
              child: Text(
                "What are you looking for?",
                textAlign: TextAlign.center, // Center the text horizontally
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20.sp, // Responsive font size
                  color: const Color(0xFF0C356A),
                ),
              ),
            ),
            SizedBox(height: 30.h), // Responsive height
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _navigateAndSaveUser(context, 'student'); // Save tenant profile type and navigate
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB900),
                      padding: EdgeInsets.symmetric(
                          vertical: 15.h, horizontal: 60.w), // Responsive padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r), // Responsive border radius
                      ),
                    ),
                    child: Text(
                      'I want to rent a place!',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16.sp, // Responsive font size
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h), // Responsive spacing
                  ElevatedButton(
                    onPressed: () {
                      _navigateAndSaveUser(context, 'landlord'); // Save landlord profile type and navigate
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C356A),
                      padding: EdgeInsets.symmetric(
                          vertical: 15.h, horizontal: 60.w), // Responsive padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r), // Responsive border radius
                      ),
                    ),
                    child: Text(
                      'I want to list my place!',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16.sp, // Responsive font size
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
