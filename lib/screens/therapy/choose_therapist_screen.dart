import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';

class ChooseTherapistScreen extends StatelessWidget {
  const ChooseTherapistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final therapists = [
      {
        'name': 'Dr. Kamal Perera',
        'specialty': 'Pediatric ADHD Specialist',
        'rating': 4.8,
        'reviews': '80+',
        'avatar':
            'https://media.istockphoto.com/id/660150716/photo/young-businessman-with-beard-smiling-towards-camera.jpg?s=612x612&w=0&k=20&c=bmOLrjsgfJziLXsfquG87i_tvjD4GsPj41HAvzRcflQ=',
      },
      {
        'name': 'Samanthi Silva, LCSW',
        'specialty': 'Trauma-Informed Therapist',
        'rating': 4.9,
        'reviews': '110+',
        'avatar':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNVTpSjkVrsFTpeXfI4BLLEUfty1iWKN27YA&s',
      },
      {
        'name': 'Peshala Gamage, PhD',
        'specialty': 'Family Systems Therapist',
        'rating': 4.6,
        'reviews': '70+',
        'avatar':
            'https://media.istockphoto.com/id/660150032/photo/portrait-of-young-businesswoman-in-pink-blouse-smiling.jpg?s=612x612&w=0&k=20&c=PYU9kX5L5HXT_ILdcobhAL91U-TQsEKEBR3dz4gsGsA=',
      },
      {
        'name': 'Dr. David De Silva',
        'specialty': 'Mindfulness Coach & Th',
        'rating': 4.7,
        'reviews': '95+',
        'avatar':
            'https://media.istockphoto.com/id/646378724/photo/portrait-of-mid-adult-man-smiling-towards-camera.jpg?s=612x612&w=0&k=20&c=ve-ZgzDmVlotwF-z0hs4G5659jXVCuqErNdRk_SHpFI=',
      },
    ];

    return Scaffold(
      bottomNavigationBar: MobileNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return; // Already on this page
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/appointments');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/task_dashboard');
          }
          // Add navigation for other indices if needed
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const TherapyAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    const Text(
                      "Choose your therapist",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Search',

                              filled: true,
                              fillColor: Colors.grey.shade200,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.filter_list,
                            color: Color(0xff8159a8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Therapist Cards Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: therapists.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.82,
                          ),
                      itemBuilder: (context, idx) {
                        final t = therapists[idx];
                        return _TherapistCard(
                          name: t['name'] as String,
                          specialty: t['specialty'] as String,
                          rating: t['rating'] as double,
                          reviews: t['reviews'] as String,
                          avatarUrl: t['avatar'] as String,
                          onViewDetails: () {
                            Navigator.pushNamed(context, '/therapist_profile');
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TherapistCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final String reviews;
  final String avatarUrl;
  final VoidCallback onViewDetails;

  const _TherapistCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.avatarUrl,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(avatarUrl), radius: 32),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            specialty,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 2),
              Text(
                rating.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                ' ($reviews)',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff8159a8),
                side: const BorderSide(color: Color(0xff8159a8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onPressed: onViewDetails,
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
