import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  Widget _featureTile(String asset, String title, String subtitle) {
    return ListTile(
      leading: Image.asset(asset, width: 50, height: 50),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 1.0,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 30),
        child: Column(
          children: [
            SizedBox(height: 30),
            Image.asset('assets/images/logowhite.png', width: 200, height: 200),
            Text(
              'Empowering ADHD Minds',
              style: TextStyle(
                fontFamily: 'Poppins',
                letterSpacing: 1.0,
                color: Colors.black87,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 32),
            _featureTile(
              'assets/images/icons/target.png',
              'Reach Your Full Potential',
              'Develop new habits and build lifelong skills with inflow',
            ),
            _featureTile(
              'assets/images/icons/shake.png',
              'Feel Understood',
              'Connect with ADHD-specialized therapists and supportive community',
            ),
            _featureTile(
              'assets/images/icons/list.png',
              'Quick and Easy',
              'Break down tasks into simple steps and create ADHD-friendly exercise habits',
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff8159a8),
                minimumSize: Size(double.infinity, 48),
              ),
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/login'),
              child: Text(
                'Log In',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  letterSpacing: 1.0,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                side: BorderSide(color: Colors.purple[100]!),
              ),
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/signup'),
              child: Text(
                'Sign Up',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  letterSpacing: 1.0,
                  fontSize: 18,
                  color: const Color(0xff8159a8),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
