import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';
import '../../services/api_service.dart';

class ChooseTherapistScreen extends StatefulWidget {
  const ChooseTherapistScreen({Key? key}) : super(key: key);

  @override
  _ChooseTherapistScreenState createState() => _ChooseTherapistScreenState();
}

class _ChooseTherapistScreenState extends State<ChooseTherapistScreen> {
  List<dynamic> therapists = [];
  List<dynamic> filteredTherapists = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';
  dynamic currentTherapist;
  bool hasTherapist = false;

  @override
  void initState() {
    super.initState();
    _fetchTherapists();
  }

  Future<void> _fetchTherapists() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result = await ApiService.getTherapists();

      if (result['success']) {
        setState(() {
          therapists = result['therapists'] ?? [];
          filteredTherapists = therapists;
          currentTherapist = result['currentTherapist'];
          hasTherapist = result['hasTherapist'] ?? false;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Failed to load therapists';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading therapists: $e';
        isLoading = false;
      });
    }
  }

  void _filterTherapists(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredTherapists = therapists;
      } else {
        filteredTherapists = therapists.where((therapist) {
          final name = therapist['name']?.toString().toLowerCase() ?? '';

          // Handle specialization as List or String
          String specialtyStr = '';
          if (therapist['specialization'] != null) {
            if (therapist['specialization'] is List) {
              specialtyStr = (therapist['specialization'] as List).join(', ');
            } else {
              specialtyStr = therapist['specialization'].toString();
            }
          }
          final specialty = specialtyStr.toLowerCase();

          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || specialty.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const TherapyAppBar(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                errorMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchTherapists,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
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

                              // Show current therapist if exists
                              if (hasTherapist && currentTherapist != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0E6FF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xff8159a8),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: currentTherapist['image'] != null
                                            ? NetworkImage(currentTherapist['image'])
                                            : const AssetImage('assets/images/logowhite.png') as ImageProvider,
                                        radius: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Your Current Therapist',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            Text(
                                              currentTherapist['name'] ?? 'Therapist',
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xff8159a8),
                                        size: 28,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 16),
                                const Text(
                                  "Browse Other Therapists",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Search and filter row
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      onChanged: _filterTherapists,
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.search),
                                        hintText: 'Search therapists...',
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

                              // Therapists list
                              if (filteredTherapists.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.search_off,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          searchQuery.isEmpty
                                              ? 'No therapists available'
                                              : 'No therapists found',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredTherapists.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.82,
                                  ),
                                  itemBuilder: (context, idx) {
                                    final therapist = filteredTherapists[idx];
                                    final isCurrentTherapist =
                                        therapist['isMyTherapist'] == true;

                                    // Handle specialization array
                                    String specialty = 'General Therapist';
                                    if (therapist['specialization'] != null) {
                                      if (therapist['specialization'] is List) {
                                        final specList = therapist['specialization'] as List;
                                        if (specList.isNotEmpty) {
                                          specialty = specList.join(', ');
                                        }
                                      } else {
                                        specialty = therapist['specialization'].toString();
                                      }
                                    }

                                    return _TherapistCard(
                                      name: therapist['name'] ?? 'Therapist',
                                      specialty: specialty,
                                      rating: (therapist['rating'] ?? 0.0)
                                          .toDouble(),
                                      reviews: therapist['sessionCount']
                                              ?.toString() ??
                                          '0',
                                      avatarUrl: therapist['image'],
                                      isCurrentTherapist: isCurrentTherapist,
                                      onViewDetails: () {
                                        // Navigate to therapist profile with ID
                                        Navigator.pushNamed(
                                          context,
                                          '/therapist_profile',
                                          arguments: therapist['id'],
                                        );
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
  final String? avatarUrl;
  final bool isCurrentTherapist;
  final VoidCallback onViewDetails;

  const _TherapistCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    this.avatarUrl,
    this.isCurrentTherapist = false,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentTherapist
            ? const Color(0xFFF0E6FF)
            : const Color(0xFFF7F3FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentTherapist
              ? const Color(0xff8159a8)
              : Colors.grey.shade200,
          width: isCurrentTherapist ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? NetworkImage(avatarUrl!)
                    : const AssetImage('assets/images/logowhite.png')
                        as ImageProvider,
                radius: 32,
              ),
              if (isCurrentTherapist)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xff8159a8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
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
                rating.toStringAsFixed(1),
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
              child: Text(
                isCurrentTherapist ? 'Your Therapist' : 'View Details',
                style: const TextStyle(
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
