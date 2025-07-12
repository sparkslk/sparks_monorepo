import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example images for featured articles (replace with your assets or network images)
    final List<String> featuredImages = [
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=200&q=80',
      'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=200&q=80',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.emergency, color: Colors.black54, size: 28),
          onPressed: () {},
        ),
        title: Center(
          child: const Text(
            'Sparks Dashboard',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.black54,
              size: 24,
            ),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xff8159a8),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MobileNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return; // Already on this page
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/appointments');
          } else if (index == 2) {
            // Stay on dashboard for sparks features
            return;
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/choose_therapist');
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              const Text(
                'Hello, Sandhavi!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ready to spark your focus today?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  letterSpacing: 1.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              // Focus & Tasks Row
              Row(
                children: [
                  Expanded(
                    child: _DashboardStatCard(
                      icon: Icons.timer,
                      title: 'Focus Time This Week',
                      value: '10m',
                      subtitle: 'Achieved your goal by 1h!',
                      color: const Color(0xff8159a8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DashboardStatCard(
                      icon: Icons.check_circle_outline,
                      title: 'Tasks Completed',
                      value: '2',
                      subtitle: 'Keep up the great work!',
                      color: const Color(0xff8159a8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Next Appointment
              const Text(
                'Next Appointment',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xff8159a8),
                      child: Icon(Icons.medical_services, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Dr. Kamal Perera',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              letterSpacing: 0.5,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'General Practitioner',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Confirmed',
                          style: TextStyle(
                            color: Colors.green,
                            fontFamily: 'Poppins',
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Text(
                              '03:30 PM',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                letterSpacing: 1.0,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: const [
                            Text(
                              '31/07/2025',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                letterSpacing: 1.0,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.calendar_today,
                              size: 15,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Featured Articles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Featured Articles',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'View all',
                    style: TextStyle(
                      color: Color(0xff8159a8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.network(
                          featuredImages[idx],
                          width: 120,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                        if (idx == 1)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.yellow.shade700,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '30%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Explore Sparks Features
              const Text(
                'Explore Sparks Features',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: Icons.forum,
                title: 'Community Forum',
                description:
                    'Connect with peers, share experiences, and get support.',
                buttonText: 'Join Discussion',
                buttonColor: const Color(0xff8159a8),
                onPressed: () {},
              ),
              const SizedBox(height: 14),
              _FeatureCard(
                icon: Icons.bolt,
                title: 'Focus & Skills',
                description:
                    'Engaging exercises to boost your concentration and comprehension.',
                buttonText: 'Start Training',
                buttonColor: const Color(0xff8159a8),
                onPressed: () {},
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final bool showProgress;

  const _DashboardStatCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    this.showProgress = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140, // Fixed height for consistent sizing
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Center(
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          if (showProgress)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: LinearProgressIndicator(
                value: 0.7,
                backgroundColor: color.withOpacity(0.15),
                color: color,
                minHeight: 5,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final Color buttonColor;
  final VoidCallback onPressed;

  const _FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.buttonColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: buttonColor.withOpacity(0.13),
            child: Icon(icon, color: buttonColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: buttonColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: onPressed,
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
