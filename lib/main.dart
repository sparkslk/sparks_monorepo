import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/welcome/splash_screen.dart';
import 'screens/welcome/onboarding_screen.dart';
import 'screens/welcome/login_screen.dart';
import 'screens/welcome/signup_screen.dart';
import 'screens/setup/setup_one.dart';
import 'screens/setup/setup_two.dart';
import 'screens/user/dashboard.dart';
import 'screens/therapy/choose_therapist_screen.dart';
import 'screens/therapy/therapist_profile_screen.dart';
import 'screens/welcome/choose.dart';
import 'screens/therapy/confirm_therapist.dart';
import 'screens/therapy/book_session_one.dart';
import 'screens/appointment/appointment.dart';
import 'screens/appointment/reschedule.dart';
import 'screens/appointment/join_session.dart';
import 'screens/appointment/past_summary.dart';
import 'widgets/not-found.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");
  runApp(SparksApp());
}

class SparksApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sparks',
      theme: ThemeData(primarySwatch: Colors.purple, fontFamily: 'Roboto'),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/setup_one': (context) => ProfileSetupStep1(),
        '/setup_two': (context) => ProfileSetupStep2(),
        '/dashboard': (context) => DashboardScreen(),
        '/choose_therapist': (context) => ChooseTherapistScreen(),
        '/therapist_profile': (context) => TherapistProfileScreen(),
        '/choose': (context) => ChooseScreen(),
        '/confirm_therapist': (context) => ConfirmTherapistPage(),
        '/book_session_one': (context) => BookSessionOnePage(),
        '/appointments': (context) => AppointmentPage(),
        '/past_summary': (context) {
          final appointment =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return SessionSummaryPage(appointment: appointment);
        },
        '/reschedule': (context) => RescheduleSessionPage(),
        '/join_session': (context) {
          final appointment =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return SessionPage(appointment: appointment);
        },
  
      },
    );
  }
}
