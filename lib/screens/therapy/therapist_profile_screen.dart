import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';
import '../../services/api_service.dart';

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

  // Therapist data
  Map<String, dynamic>? therapistData;
  bool isLoading = true;
  bool isAssigningTherapist = false;
  String errorMessage = '';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch therapist data when dependencies are ready
    if (therapistData == null && !isLoading) return;
    if (therapistData == null) {
      _fetchTherapistData();
    }
  }

  String? _therapistId; // Store therapistId for later use

  Future<void> _fetchTherapistData() async {
    final therapistId = ModalRoute.of(context)?.settings.arguments as String?;

    if (therapistId == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'No therapist ID provided';
      });
      return;
    }

    _therapistId = therapistId; // Save therapistId

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result = await ApiService.getTherapistById(therapistId);

      if (result['success']) {
        setState(() {
          therapistData = result['therapist'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Failed to load therapist details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading therapist: $e';
        isLoading = false;
      });
    }
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: const TherapyAppBar(
        title: 'Therapist Profile',
        showBackButton: true,
      ),
      bottomNavigationBar: MobileNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/appointments');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/task_dashboard');
          }
        },
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchTherapistData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Enhanced Profile Card
                            _buildProfileCard(),
                            const SizedBox(height: 28),

                            // About Section
                            _buildAboutSection(),
                            const SizedBox(height: 28),

                            // Specializations Section
                            _buildSpecializationsSection(),
                            const SizedBox(height: 28),

                            // Reviews Section
                            // _buildReviewsSection(),
                            // const SizedBox(height: 32),

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

  Widget _buildProfileCard() {
    final name = therapistData?['name'] ?? 'Therapist';
    final avatarUrl = therapistData?['image'];
    final rating = (therapistData?['rating'] ?? 0.0).toDouble();
    final patientCount = therapistData?['patientCount'] ?? 0;
    final experience = therapistData?['experience'] ?? 0;

    // Get first specialization as main specialty
    String mainSpecialty = 'General Therapist';
    if (therapistData?['specialization'] != null) {
      if (therapistData?['specialization'] is List && (therapistData?['specialization'] as List).isNotEmpty) {
        mainSpecialty = (therapistData?['specialization'] as List).first.toString();
      }
    }

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
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? Image.network(
                          avatarUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: const Color(0xFFF0E6FF),
                              child: const Icon(Icons.person, size: 40, color: Color(0xff8159a8)),
                            );
                          },
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: const Color(0xFFF0E6FF),
                          child: const Icon(Icons.person, size: 40, color: Color(0xff8159a8)),
                        ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mainSpecialty,
                      style: const TextStyle(
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
                        Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            therapistData?['email'] ?? '',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              letterSpacing: 0.5,
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
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
          _ProfileStatsRow(
            rating: rating,
            patientCount: patientCount,
            experience: experience,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    final name = therapistData?['name'] ?? 'Therapist';
    final firstName = name.split(' ').first;
    final bio = therapistData?['bio'] ?? 'No biography available.';

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
              Text(
                'About $firstName',
                style: const TextStyle(
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
          Text(
            bio,
            style: const TextStyle(
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
    List<String> specializations = [];

    if (therapistData?['specialization'] != null) {
      if (therapistData?['specialization'] is List) {
        specializations = (therapistData?['specialization'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    if (specializations.isEmpty) {
      specializations = ['General Therapy'];
    }

    // Icon mapping for common specializations
    IconData getIconForSpecialization(String spec) {
      final lowerSpec = spec.toLowerCase();
      if (lowerSpec.contains('anxiety')) return Icons.psychology;
      if (lowerSpec.contains('depression')) return Icons.mood_bad;
      if (lowerSpec.contains('trauma')) return Icons.healing;
      if (lowerSpec.contains('cognitive') || lowerSpec.contains('cbt')) return Icons.mic;
      if (lowerSpec.contains('family') || lowerSpec.contains('couples')) return Icons.family_restroom;
      if (lowerSpec.contains('child')) return Icons.child_care;
      if (lowerSpec.contains('addiction')) return Icons.local_hospital;
      return Icons.psychology_alt; // Default icon
    }

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
                    Icon(getIconForSpecialization(spec), size: 16, color: const Color(0xff8159a8)),
                    const SizedBox(width: 6),
                    Text(
                      spec,
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
            height: 200,
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
            onPressed: isAssigningTherapist
                ? null
                : () async {
                    // Assign therapist first, then navigate to booking screen
                    if (_therapistId != null) {
                      setState(() {
                        isAssigningTherapist = true;
                      });

                      try {
                        final result =
                            await ApiService.assignTherapist(_therapistId!);

                        setState(() {
                          isAssigningTherapist = false;
                        });

                        if (result['success']) {
                          // Show success message if this is a new assignment
                          if (result['assigned'] == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ??
                                    'Therapist assigned successfully'),
                                backgroundColor: const Color(0xff8159a8),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }

                          // Navigate to booking screen
                          Navigator.pushNamed(
                            context,
                            '/book_session_one',
                            arguments: _therapistId,
                          );
                        } else {
                          // Show error dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Column(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red, size: 48),
                                    SizedBox(height: 16),
                                    Text(
                                      'Assignment Failed',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        letterSpacing: 0.5,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                content: Text(
                                  result['message'] ??
                                      'Failed to assign therapist',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    letterSpacing: 0.5,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text('OK'),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } catch (e) {
                        setState(() {
                          isAssigningTherapist = false;
                        });
                        // Show error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
            child: isAssigningTherapist
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_month, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Book Appointment',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            letterSpacing: 0.5,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
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
  final double rating;
  final int patientCount;
  final int experience;

  const _ProfileStatsRow({
    required this.rating,
    required this.patientCount,
    required this.experience,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(
          icon: Icons.star,
          label: 'RATING',
          value: rating.toStringAsFixed(1),
        ),
        const SizedBox(width: 12),
        _StatBox(
          icon: Icons.people,
          label: 'PATIENTS',
          value: patientCount > 0 ? '$patientCount' : '0',
        ),
        const SizedBox(width: 12),
        _StatBox(
          icon: Icons.school,
          label: 'EXPERIENCE',
          value: experience > 0 ? '$experience Years' : 'New',
        ),
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
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xff8159a8).withOpacity(0.3), width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    avatarUrl,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0E6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 20,
                          color: Color(0xff8159a8),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0E6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: const Color(0xff8159a8),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
          Text(
            review,
            style: const TextStyle(
              fontFamily: 'Poppins',
              letterSpacing: 0.5,
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}