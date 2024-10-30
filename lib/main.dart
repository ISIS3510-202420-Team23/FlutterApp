import 'package:andlet/analytics/analytics_engine.dart';
import 'package:andlet/view/common/welcome_page.dart';
import 'package:andlet/view_models/offer_view_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'cas/location_service.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:logging_to_logcat/logging_to_logcat.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added for responsiveness
import 'models/entities/offer.dart';
import 'models/entities/offer_property.dart';
import 'models/entities/property.dart';
import 'view/auth/bloc/auth_bloc.dart';
import 'view_models/property_view_model.dart';
import 'view_models/user_view_model.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async {
  await _initializeApp();

  // Create an instance of LocationService and start tracking
  LocationService locationService = LocationService();

  locationService.startTracking();
  locationService.initializeNotifications();
  runApp(MyApp(locationService: locationService));
}

/// Initialize the app
Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up hive (Cache)
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(PropertyAdapter());
  Hive.registerAdapter(OfferAdapter());
  Hive.registerAdapter(OfferPropertyAdapter());
  await Hive.openBox<Property>('properties');
  await Hive.openBox<Offer>('offers');
  await Hive.openBox<OfferProperty>('offer_properties');

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize and Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Analytics
  AnalyticsEngine.initializeAnalytics();

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
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Define your base screen size
      builder: (context, child) {
        return MultiProvider(
          providers: [
            // Include PropertyViewModel as a ChangeNotifierProvider
            ChangeNotifierProvider(create: (_) => PropertyViewModel()),
            ChangeNotifierProvider(create: (_) => OfferViewModel()),
            ChangeNotifierProvider(create: (_) => UserViewModel()),
          ],
          child: MultiBlocProvider(
            providers: [
              // Existing AuthBloc
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
      },
    );
  }
}
