import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger('AuthBloc');

  AuthBloc() : super(AuthInitial()) {
    // Handle Email/Password login
    on<LoginRequested>(_onLoginRequested);

    // Handle Google Sign-In
    on<GoogleLoginRequested>(_onGoogleLoginRequested);

    // Handle Logout
    on<LogoutRequested>(_onLogoutRequested);
  }

  // Method to handle LoginRequested event
  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Perform email/password login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(userEmail: userCredential.user?.email ?? ''));
    } catch (e) {
      emit(AuthError(message: 'Login failed: ${e.toString()}'));
    }
  }

  // Method to handle GoogleLoginRequested event
  Future<void> _onGoogleLoginRequested(GoogleLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await _auth.signInWithCredential(credential);
        // Navigate to Profile Picker after successful Google login
        emit(ProfilePickerSuccess(userEmail: userCredential.user?.email ?? ''));
      } else {
        emit(const AuthError(message: 'Google Sign-In aborted by user.'));
      }
    } catch (e) {
      emit(AuthError(message: 'Google Sign-In failed: ${e.toString()}'));
    }
  }

  // Method to handle LogoutRequested event
  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    _logger.info('LogoutRequested event triggered');
    await _auth.signOut();
    emit(Unauthenticated());
    _logger.info('User logged out successfully');
  }
}