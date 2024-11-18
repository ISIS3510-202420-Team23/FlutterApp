import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import for responsiveness
import '../../../connectivity/connectivity_service.dart';
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
  final Logger log = Logger('LoginView');

  bool _isConnected = true;
  final ConnectivityService _connectivityService = ConnectivityService();
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    log.info('Initializing connectivity check...');
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      log.info('Connectivity changed: $result');
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) async {
    bool isConnected = result != ConnectivityResult.none &&
        await _connectivityService.isConnected();
    log.info('Updated connectivity status: $isConnected');
    setState(() {
      _isConnected = isConnected;
    });

    if (isConnected) {
      log.info('Online - Refreshing data from Firestore in background');
    }
  }

  /// Function to check profile type and navigate accordingly
  Future<void> _checkProfileAndNavigate(BuildContext context,
      String displayName, String photoUrl, String userEmail) async {
    // Perform the async operation first
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final profileType = prefs.getString('profileType');

    // Ensure the context is still valid after the async operation
    log.info('Profile type: $profileType');
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
    await prefs.clear(); // Clear local storage
    await FirebaseAuth.instance.signOut(); // Sign out from Firebase
    log.info("Session cleared and user signed out.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC5DDFF),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Check if state is either ProfilePickerSuccess or Authenticated
          if (state is ProfilePickerSuccess) {
            log.info('Authentication successful for user: ${state.userEmail}');
            _checkProfileAndNavigate(
                context, state.displayName, state.photoUrl, state.userEmail);
          } else if (state is Authenticated) {
            log.info('Authentication successful for user: ${state.userEmail}');
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
            padding: EdgeInsets.all(30.r), // Responsive padding
            child: Column(
              children: [
                // Top section with welcome text aligned to the left
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40.h), // Responsive height
                      Text(
                        'Welcome to \nAndlet!',
                        style: TextStyle(
                          fontFamily: 'League Spartan',
                          fontSize: 42.sp, // Responsive font size
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0C356A),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Sign-in to access \nyour account',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 25.sp, // Responsive font size
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF0C356A),
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
                          log.info('Navigating to Google register');
                          await _clearSession();
                          if (context.mounted) {
                            // Clear session when trying to register
                            BlocProvider.of<AuthBloc>(context)
                                .add(const GoogleSignupRequested());
                          }
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'New Member? ',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15.sp, // Responsive font size
                              color: const Color(0xFF0C356A),
                            ),
                            children: [
                              TextSpan(
                                text: 'Register now',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15.sp, // Responsive font size
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0C356A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // Google Sign-up Button
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (!_isConnected) {
                            _showOfflineSnackbar();
                            return;
                          }

                          log.info('Attempting Google Sign-Up');
                          await _clearSession();
                          if (context.mounted) {
                            BlocProvider.of<AuthBloc>(context)
                                .add(const GoogleSignupRequested());
                          }
                        },
                        icon: Image.asset('lib/assets/google.png',
                            height: 20.h), // Responsive icon size
                        label: Text(
                          'Sign up with Google',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18.sp, // Responsive font size
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 15.h,
                              horizontal: 40.w), // Responsive padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                30.r), // Responsive border radius
                          ),
                          elevation: 5,
                        ),
                      ),
                      SizedBox(height: 30.h),
                      // Divider with 'Or log in with Email'
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: Color(0xFF0C356A))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Text(
                              'Or log in with Email',
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15.sp, // Responsive font size
                                  color: const Color(0xFF0C356A)),
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: Color(0xFF0C356A))),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      // Google Log-in Button
                      ElevatedButton.icon(
                        onPressed: () {
                          if (!_isConnected) {
                            _showOfflineSnackbar();
                            return;
                          }

                          log.info('Attempting Google Login');
                          BlocProvider.of<AuthBloc>(context)
                              .add(const GoogleLoginRequested());
                        },
                        icon: Image.asset('lib/assets/google.png',
                            height: 20.h), // Responsive icon size
                        label: Text(
                          'Log in with Google',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18.sp, // Responsive font size
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 15.h,
                              horizontal: 40.w), // Responsive padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                30.r), // Responsive border radius
                          ),
                          elevation: 5,
                        ),
                      ),
                      SizedBox(height: 5.h),
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
                          Text(
                            'Remember me',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16.sp, // Responsive font size
                              color: const Color(0xFF0C356A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Align the dots at the left-bottom side
                Padding(
                  padding: EdgeInsets.only(
                      bottom: 40.h, left: 10.w), // Responsive padding
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        Container(
                          width: 10.w, // Responsive size
                          height: 10.h, // Responsive size
                          decoration: const BoxDecoration(
                            color: Color(0xFFF9A826),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Container(
                          width: 10.w,
                          height: 10.h,
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
          );
        },
      ),
    );
  }

  /// Function to show a snackbar when user is offline
  void _showOfflineSnackbar() {
    log.warning('User attempted to login while offline.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 6),
        content: Text(
          "You are offline. Can't Login or Sign Up.",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
