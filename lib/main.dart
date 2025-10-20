import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/welcome/splash_screen.dart';
import 'screens/welcome/onboarding_screen.dart';
import 'screens/welcome/login_screen.dart';
import 'screens/welcome/signup_screen.dart';
import 'screens/setup/setup_one.dart';
import 'screens/setup/setup_two.dart';
import 'screens/setup/setup_three.dart';
import 'screens/setup/welcome_screen.dart';
import 'screens/user/dashboard.dart';
import 'screens/user/profile_page.dart';
import 'screens/user/relaxation_page.dart';
import 'screens/user/blog_list_page.dart';
import 'screens/user/blog_detail_page.dart';
import 'screens/therapy/choose_therapist_screen.dart';
import 'screens/therapy/therapist_profile_screen.dart';
import 'screens/welcome/choose.dart';
import 'screens/therapy/confirm_therapist.dart';
import 'screens/therapy/book_session_one.dart';
import 'screens/therapy/payment_review_screen.dart';
import 'screens/therapy/payment_confirmation_screen.dart';
import 'screens/appointment/appointment.dart';
import 'screens/appointment/reschedule.dart';
import 'screens/appointment/join_session.dart';
import 'screens/appointment/past_summary.dart';
import 'screens/appointment/cancel_appointment_screen.dart';
import 'screens/appointment/cancel_confirmation_screen.dart';
import 'screens/task/dashboard.dart';
import 'screens/task/add_task.dart';
import 'screens/task/pomodoro_timer.dart';
import 'screens/task/completed_task.dart';
import 'screens/task/day_tasks.dart';
import 'screens/quiz/adhd_quiz_screen.dart';
import 'screens/quiz/adhd_quiz_results_screen.dart';
import 'widgets/not-found.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");
  // Initialize notifications & schedule daily check (non-blocking)
  NotificationService.I.init().then(
    (_) => NotificationService.I.scheduleDailyIncompleteTasksCheck(),
  );
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
        '/welcome': (context) => WelcomeScreen(),
        '/adhd_quiz': (context) => AdhdQuizScreen(),
        '/adhd_quiz_results': (context) => AdhdQuizResultsScreen(),
        '/setup_one': (context) => ProfileSetupStep1(),
        '/setup_two': (context) => ProfileSetupStep2(),
        '/setup_three': (context) => ProfileSetupStep3(),
        '/dashboard': (context) => DashboardScreen(),
        '/profile': (context) => ProfilePage(),
        '/relaxation': (context) => RelaxationPage(),
        '/blog_list': (context) => BlogListPage(),
        '/blog_detail': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return BlogDetailPage(blogId: args['blogId'] as String);
        },
        '/choose_therapist': (context) => ChooseTherapistScreen(),
        '/therapist_profile': (context) => TherapistProfileScreen(),
        '/choose': (context) => ChooseScreen(),
        '/confirm_therapist': (context) => ConfirmTherapistPage(),
        '/book_session_one': (context) => BookSessionOnePage(),
        '/payment_review': (context) => PaymentReviewScreen(),
        '/payment_confirmation': (context) => PaymentConfirmationScreen(),
        '/appointments': (context) => AppointmentPage(),
        '/task_dashboard': (context) => TaskDashboardPage(),
        '/add_task': (context) => NewTasksPage(),
        '/pomodoro_timer': (context) => PomodoroTimerPage(),
        '/completed_tasks': (context) => CompletedTasksPage(),
        '/day_tasks': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return CompletedDayTasksPage(taskId: args['taskId'] as String);
        },
        '/past_summary': (context) {
          final appointment =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return SessionSummaryPage(appointment: appointment);
        },
        '/reschedule': (context) => RescheduleSessionPage(),
        '/cancel_appointment': (context) => CancelAppointmentScreen(),
        '/cancel_confirmation': (context) => CancelConfirmationScreen(),
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
