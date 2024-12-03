import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  bool _isConnected = true; // Track connectivity status
  final ConnectivityService _connectivityService = ConnectivityService();
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    log.info('Initializing connectivity check...');
    final initialStatus = await _connectivity.checkConnectivity();
    _updateConnectionStatus(initialStatus);

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
  }

  /// Function to check profile type and navigate accordingly
  Future<void> _checkProfileAndNavigate(
      BuildContext context,
      String displayName,
      String photoUrl,
      String userEmail,
      ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final profileType = prefs.getString('profileType');

    log.info('Profile type: $profileType');
    if (context.mounted) {
      if (profileType == 'student') {
        // Navigate to ExploreView
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
        // Navigate to ProfilePickerView
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
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0C356A),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.all(30.r),
            child: Column(
              children: [
                // Welcome Text Section
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40.h),
                      Text(
                        'Welcome to \nAndlet!',
                        style: TextStyle(
                          fontFamily: 'League Spartan',
                          fontSize: 42.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0C356A),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Sign-in to access \nyour account',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 25.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF0C356A),
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Section with Buttons
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          log.info('Navigating to Google register');
                          await _clearSession();
                          if (!_isConnected) {
                            _showOfflineSnackbar();
                            return;
                          }
                          if (context.mounted) {
                            BlocProvider.of<AuthBloc>(context)
                                .add(const GoogleSignupRequested());
                          }
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'New Member? ',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15.sp,
                              color: const Color(0xFF0C356A),
                            ),
                            children: [
                              TextSpan(
                                text: 'Register now',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15.sp,
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
                        icon: Image.asset('lib/assets/google.png', height: 20.h),
                        label: Text(
                          'Sign up with Google',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18.sp,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 15.h, horizontal: 40.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          elevation: 5,
                        ),
                      ),
                      SizedBox(height: 30.h),
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
                                  fontSize: 15.sp,
                                  color: const Color(0xFF0C356A)),
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: Color(0xFF0C356A))),
                        ],
                      ),
                      SizedBox(height: 10.h),
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
                        icon: Image.asset('lib/assets/google.png', height: 20.h),
                        label: Text(
                          'Log in with Google',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18.sp,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 15.h, horizontal: 40.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          elevation: 5,
                        ),
                      ),
                      SizedBox(height: 5.h),
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
                            activeColor: const Color(0xFF0C356A),
                          ),
                          Text(
                            'Remember me',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16.sp,
                              color: const Color(0xFF0C356A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Show snackbar for offline restriction
  void _showOfflineSnackbar() {
    log.warning('User attempted to login while offline.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "You are offline. Can't Login or Sign Up.",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
