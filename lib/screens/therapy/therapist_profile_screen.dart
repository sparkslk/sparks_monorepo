import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';

class TherapistProfileScreen extends StatefulWidget {
  const TherapistProfileScreen({Key? key}) : super(key: key);

  @override
  State<TherapistProfileScreen> createState() => _TherapistProfileScreenState();
}

class _TherapistProfileScreenState extends State<TherapistProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  PageController _reviewPageController = PageController();
  int _currentReviewPage = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _reviewPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const avatarUrl =
        'https://media.istockphoto.com/id/660150716/photo/young-businessman-with-beard-smiling-towards-camera.jpg?s=612x612&w=0&k=20&c=bmOLrjsgfJziLXsfquG87i_tvjD4GsPj41HAvzRcflQ=';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      bottomNavigationBar: MobileNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/appointments');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        },
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TherapyAppBar(),
                  const SizedBox(height: 24),

                  // Enhanced Profile Card
                  _buildProfileCard(avatarUrl),
                  const SizedBox(height: 28),

                  // About Section
                  _buildAboutSection(),
                  const SizedBox(height: 28),

                  // Specializations Section
                  _buildSpecializationsSection(),
                  const SizedBox(height: 28),

                  // Availability Section
                  _buildAvailabilitySection(),
                  const SizedBox(height: 28),

                  // Reviews Section
                  _buildReviewsSection(),
                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(String avatarUrl) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7F3FF), Color(0xFFEDE7F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff8159a8).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Avatar
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xff8159a8).withOpacity(0.3), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff8159a8).withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    avatarUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Dr. Kamal Perera',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'General Practitioner',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        letterSpacing: 0.5,
                        fontSize: 15,
                        color: Color(0xff8159a8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Colombo, Sri Lanka',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            letterSpacing: 0.5,
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Enhanced Stats Row
          const _ProfileStatsRow(),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: const Color(0xff8159a8), size: 20),
              const SizedBox(width: 8),
              const Text(
                'About Dr. Kamal',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xff8159a8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Dr. Kamal Perera is a dedicated General Practitioner known for his compassionate patient care and clinical expertise. With years of experience in diagnosing and treating a wide range of health conditions, he emphasizes preventive care and holistic wellness. Dr. Perera is trusted for his approachable nature and commitment to community health.',
            style: TextStyle(
              fontFamily: 'Poppins',
              letterSpacing: 0.5,
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationsSection() {
    final specializations = [
      {'name': 'Anxiety Disorders', 'icon': Icons.psychology},
      {'name': 'Depression', 'icon': Icons.mood_bad},
      {'name': 'Trauma Therapy', 'icon': Icons.healing},
      {'name': 'Cognitive Behavioral Therapy', 'icon': Icons.mic},
      {'name': 'Family Counseling', 'icon': Icons.family_restroom},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: const Color(0xff8159a8), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Specializations',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xff8159a8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: specializations.map((spec) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xff8159a8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xff8159a8).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(spec['icon'] as IconData, size: 16, color: const Color(0xff8159a8)),
                    const SizedBox(width: 6),
                    Text(

                      spec['name'] as String,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        letterSpacing: 0.5,
                        color: Color(0xff8159a8),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: const Color(0xff8159a8), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Availability',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xff8159a8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAvailabilityItem('Today', '2:00 PM - 6:00 PM', true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAvailabilityItem('Tomorrow', '9:00 AM - 5:00 PM', true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAvailabilityItem('This Week', '15 slots available', false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityItem(String title, String time, bool isAvailable) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAvailable
            ? const Color(0xff8159a8).withOpacity(0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable
              ? const Color(0xff8159a8).withOpacity(0.3)
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isAvailable ? const Color(0xff8159a8) : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontFamily: 'Poppins',
              letterSpacing: 0.5,
              fontSize: 12,
              color: isAvailable ? const Color(0xff8159a8) : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.reviews, color: const Color(0xff8159a8), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Reviews',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xff8159a8),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    letterSpacing: 0.5,
                    color: Color(0xff8159a8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: PageView(
              controller: _reviewPageController,
              onPageChanged: (index) {
                setState(() {
                  _currentReviewPage = index;
                });
              },
              children: [
                _ReviewCard(
                  name: 'Shanuka Perera',
                  date: 'A day ago',
                  rating: 5,
                  review: 'Dr. Kamal Perera is kind, attentive, and always takes time to listen. His accurate diagnoses and caring approach make every visit comfortable.',
                  avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
                ),
                _ReviewCard(
                  name: 'Saman Gamage',
                  date: '2 days ago',
                  rating: 4,
                  review: 'Dr. Kamal Perera is an excellent GP. He explains everything clearly and genuinely cares about his patients. I always feel reassured.',
                  avatarUrl: 'https://randomuser.me/api/portraits/men/31.jpg',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Enhanced Page indicator
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(2, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentReviewPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentReviewPage == index
                        ? const Color(0xff8159a8)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff8159a8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/confirm_therapist');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Book Appointment',
                  style: TextStyle( fontFamily: 'Poppins',
                      letterSpacing: 0.5,fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xff8159a8),
              side: const BorderSide(color: Color(0xff8159a8), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 20),
                SizedBox(width: 8),
                Text(
                  'Browse Other Therapists',
                  style: TextStyle( fontFamily: 'Poppins',
                      letterSpacing: 0.5,fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(icon: Icons.star, label: 'RATING', value: '4.5'),
        const SizedBox(width: 12),
        _StatBox(icon: Icons.people, label: 'PATIENTS', value: '1000+'),
        const SizedBox(width: 12),
        _StatBox(icon: Icons.school, label: 'EXPERIENCE', value: '10+ Years'),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xff8159a8).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff8159a8).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xff8159a8), size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                letterSpacing: 0.5,
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String date;
  final int rating;
  final String review;
  final String avatarUrl;

  const _ReviewCard({
    required this.name,
    required this.date,
    required this.rating,
    required this.review,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff8159a8).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xff8159a8).withOpacity(0.3)),
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrl),
                  radius: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: index < rating ? Colors.amber : Colors.grey.shade400,
                              size: 16,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        letterSpacing: 0.5,
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              review,
              style: const TextStyle(
                fontFamily: 'Poppins',
                letterSpacing: 0.5,
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}