import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:logging/logging.dart';
import 'package:andlet/view/profile_selection/views/profile_picker_view.dart';
import 'package:andlet/view/explore/views/explore_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  bool rememberMe = false; // Variable to track checkbox state
  final Logger _logger = Logger('LoginView');

  /// Function to check profile type and navigate accordingly
  Future<void> _checkProfileAndNavigate(
      BuildContext context, String displayName, String photoUrl, String userEmail) async {
    // Perform the async operation first
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final profileType = prefs.getString('profileType');

    // Ensure the context is still valid after the async operation
    _logger.info('Profile type: $profileType');
    if (context.mounted) {
      if (profileType == 'student') {
        // If user is already a tenant, navigate directly to ExploreView
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExploreView(
              displayName: displayName,
              photoUrl: photoUrl,
              userEmail: userEmail,
            ),
          ),
        );
      } else {
        // If no profile type set, navigate to ProfilePickerView
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePickerView(
              displayName: displayName,
              photoUrl: photoUrl,
              userEmail: userEmail,
            ),
          ),
        );
      }
    }
  }

  Future<void> _clearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();  // Clear local storage
    await FirebaseAuth.instance.signOut();  // Sign out from Firebase
    _logger.info("Session cleared and user signed out.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC5DDFF),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Check if state is either ProfilePickerSuccess or Authenticated
          if (state is ProfilePickerSuccess) {
            _logger
                .info('Authentication successful for user: ${state.userEmail}');
            _checkProfileAndNavigate(
                context, state.displayName, state.photoUrl, state.userEmail);
          } else if (state is Authenticated) {
            _logger
                .info('Authentication successful for user: ${state.userEmail}');
            _checkProfileAndNavigate(
                context, state.displayName, state.photoUrl, state.userEmail);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            // Show a loader when the login/signup is in progress
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0C356A),
              ), // Center the loader on screen
            );
          }
          return Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                // Top section with welcome text aligned to the left
                const Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40), // Adjust the top space
                      Text(
                        'Welcome to \nAndlet!',
                        style: TextStyle(
                          fontFamily: 'League Spartan',
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0C356A),
                        ),
                      ),
                      SizedBox(height: 0),
                      Text(
                        'Sign-in to access \nyour account',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 25,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF0C356A),
                        ),
                      ),
                    ],
                  ),
                ),
                // Centered section with buttons and other elements
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // New Member Link with "Register now" in bold
                      GestureDetector(
                        onTap: () async {
                          _logger.info('Navigating to Google register');
                          await _clearSession();
                          if (context.mounted) { // Clear session when trying to register
                            BlocProvider.of<AuthBloc>(context).add(
                                const GoogleSignupRequested());
                          }
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: 'New Member? ',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15,
                              color: Color(0xFF0C356A),
                            ),
                            children: [
                              TextSpan(
                                text: 'Register now',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0C356A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Google Sign-up Button
                      ElevatedButton.icon(
                        onPressed: () async {
                          _logger.info('Attempting Google Sign-Up');
                          await _clearSession();
                          if (context.mounted) {
                            BlocProvider.of<AuthBloc>(context).add(
                                const GoogleSignupRequested());
                          }
                        },
                        icon: Image.asset('lib/assets/google.png', height: 20),
                        label: const Text(
                          'Sign up with Google',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Divider with 'Or log in with Email'
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFF0C356A))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Or log in with Email',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  color: Color(0xFF0C356A)),
                            ),
                          ),
                          Expanded(child: Divider(color: Color(0xFF0C356A))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Google Log-in Button
                      ElevatedButton.icon(
                        onPressed: () {
                          _logger.info('Attempting Google Login');
                          BlocProvider.of<AuthBloc>(context).add(const GoogleLoginRequested());
                        },
                        icon: Image.asset('lib/assets/google.png', height: 20),
                        label: const Text(
                          'Log in with Google',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Remember me checkbox
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (bool? value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                            activeColor: const Color(
                                0xFF0C356A), // Set fill color when checked
                          ),
                          const Text(
                            'Remember me',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              color: Color(0xFF0C356A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Align the dots at the left-bottom side
                Padding(
                  padding: const EdgeInsets.only(bottom: 40, left: 10),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
