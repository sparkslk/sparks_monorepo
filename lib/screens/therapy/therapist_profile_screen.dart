import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';

class TherapistProfileScreen extends StatelessWidget {
  const TherapistProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example avatar image
    const avatarUrl =
        'https://media.istockphoto.com/id/660150716/photo/young-businessman-with-beard-smiling-towards-camera.jpg?s=612x612&w=0&k=20&c=bmOLrjsgfJziLXsfquG87i_tvjD4GsPj41HAvzRcflQ=';

    return Scaffold(
      bottomNavigationBar: MobileNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return; // Already on this page
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
          // Add navigation for other indices if needed
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(width: 32), // for symmetry
                  Expanded(
                    child: Center(
                      child: Text(
                        "Therapist's profile",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  Icon(Icons.notifications_none, color: Colors.black54),
                ],
              ),
              const SizedBox(height: 18),
              // Profile Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        avatarUrl,
                        width: 66,
                        height: 66,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Dr. Kamal Perera',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'General Practitioner',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 18),
                          // Stats Row
                          _ProfileStatsRow(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              // About
              const Text(
                'About',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff8159a8),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Dr. Kamal Perera is a dedicated General Practitioner known for his compassionate patient care and clinical expertise. With years of experience in diagnosing and treating a wide range of health conditions, he emphasizes preventive care and holistic wellness. Dr. Perera is trusted for his approachable nature and commitment to community health.',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 18),
              // Reviews
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Reviews',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff8159a8),
                    ),
                  ),
                  Text(
                    'See all',
                    style: TextStyle(
                      color: Color(0xff8159a8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: PageView(
                  children: [
                    _ReviewCard(
                      name: 'Shanuka Perera',
                      date: 'A day ago',
                      rating: 5,
                      review:
                          'Dr. Kamal Perera is kind, attentive, and always takes time to listen. His accurate diagnoses and caring approach make every visit comfortable. I trust him completely with my health.',
                      avatarUrl:
                          'https://randomuser.me/api/portraits/men/32.jpg',
                    ),
                    _ReviewCard(
                      name: 'Saman Gamage',
                      date: '2 days ago',
                      rating: 4,
                      review:
                          'Dr. Kamal Perera is an excellent GP. He explains everything clearly and genuinely cares about his patients. I always feel reassured and well looked after during every appointment.',
                      avatarUrl:
                          'https://randomuser.me/api/portraits/men/31.jpg',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Page indicator
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Color(0xff8159a8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              // Choose Therapist Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff8159a8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Choose Therapist',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 128, 88, 168),
                    side: const BorderSide(color: Color(0xff8159a8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'View Other Therapists',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
        const SizedBox(width: 8),
        _StatBox(icon: Icons.people, label: 'PATIENTS', value: '1000+'),
        const SizedBox(width: 8),
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
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Color(0xff8159a8), size: 18),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
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
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(avatarUrl), radius: 20),
          const SizedBox(width: 10),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        children: List.generate(
                          rating,
                          (index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    date,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
