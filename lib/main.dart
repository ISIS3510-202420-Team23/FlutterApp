import 'package:andlet/view/common/welcome_page.dart';
import 'package:andlet/view_models/offer_view_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'cas/location_service.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:logging_to_logcat/logging_to_logcat.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'view/auth/bloc/auth_bloc.dart';
import 'view_models/property_view_model.dart';

void main() async {
  await _initializeApp();

  // Create an instance of LocationService and start tracking
  LocationService locationService = LocationService();
  locationService.startTracking();

  runApp(MyApp(locationService: locationService));
}

/// Initialize the app
Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up logging
  _setupLogging();
}

/// Set up logging
void _setupLogging() {
  Logger.root.level = Level.ALL; // Set the logging level
  Logger.root.activateLogcat(); // Enable Logcat logging on Android
  final Logger log = Logger('Main');
  log.info('App initialized successfully!');
}

class MyApp extends StatelessWidget {
  final LocationService locationService;

  const MyApp({super.key, required this.locationService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PropertyViewModel()),
        ChangeNotifierProvider(create: (_) => OfferViewModel()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        ],
        child: MaterialApp(
          title: 'Andlet App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const WelcomePage(),
        ),
      ),
    );
  }
}
