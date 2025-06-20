import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  Widget _featureTile(String asset, String title, String subtitle) {
    return ListTile(
      leading: Image.asset(asset, width: 40, height: 40),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 30),
        child: Column(
          children: [
            SizedBox(height: 30),
            Image.asset(
              'assets/logowhite.png',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 8),
            Text('SPARKS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
            Text('Empowering ADHD Minds', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
            SizedBox(height: 28),
            _featureTile('assets/logowhite.png', 'Reach Your Full Potential', 'Develop new habits and build lifelong skills with inflow'),
            _featureTile('assets/logowhite.png', 'Feel Understood', 'Connect with ADHD-specialized therapists and supportive community'),
            _featureTile('assets/logowhite.png', 'Quick and Easy', 'Break down tasks into simple steps and create ADHD-friendly exercise habits'),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(double.infinity, 48),
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: Text('Log In', style: TextStyle(color: Colors.white),),
            ),
            SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                side: BorderSide(color: Colors.purple[100]!),
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
              child: Text('Sign Up', style: TextStyle(color: Colors.purple)),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
