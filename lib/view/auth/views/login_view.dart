import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:logging/logging.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});


  @override
  _LoginViewState createState() => _LoginViewState();

}

class _LoginViewState extends State<LoginView> {
  bool rememberMe = false; // Variable to track checkbox state
  final Logger _logger = Logger('LoginView');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC5DDFF),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            _logger.info('Authentication successful for user: ${state.userEmail}');
            //Navigator.pushNamed(context, '/home');
          } else if (state is AuthError) {
            _logger.severe('Authentication error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                      'Welcome to Andlet!',
                      style: TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0C356A),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Sign-in to access your account',
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
              const SizedBox(height: 0), // Positive spacing between top text and the buttons

              // Centered section with buttons and other elements
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // New Member Link with "Register now" in bold
                    GestureDetector(
                      onTap: () {
                        _logger.info('Navigating to register');
                        // Handle register now navigation
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
                      onPressed: () {
                        _logger.info('Attempting Google Sign-Up');
                        BlocProvider.of<AuthBloc>(context).add(const GoogleLoginRequested());
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
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
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
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 15, color: Color(0xFF0C356A)),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFF0C356A))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Google Log-in Button
                    ElevatedButton.icon(
                      onPressed: () {
                        // Trigger Google Login
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
                    const SizedBox(height: 15),
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
                          activeColor: const Color(0xFF0C356A), // Set fill color when checked
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
            ],
          ),
        ),
      ),
    );
  }
}
