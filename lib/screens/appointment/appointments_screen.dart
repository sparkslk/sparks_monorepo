import 'package:flutter/material.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int selectedTab = 1; // 0: Upcoming, 1: Completed, 2: Canceled

  final appointments = [
    {
      'date': '2023-11-15',
      'therapist': 'Dr. Emily White',
      'type': 'CBT Session',
      'desc':
          'Focused on cognitive restructuring techniques. Discussed challenging negative thought patterns related to self-worth. Identified triggers for',
    },
    {
      'date': '2023-10-28',
      'therapist': 'Dr. Johnathan Blake',
      'type': 'Mindfulness Coaching',
      'desc':
          'Explored guided meditation and breathing exercises. Discussed the importance of presence and acceptance in managing daily',
    },
    {
      'date': '2023-10-01',
      'therapist': 'Dr. Emily White',
      'type': 'Initial Consultation',
      'desc':
          'Comprehensive assessment of current challenges and therapy goals. Established a foundational understanding of client history and',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  const Text(
                    'Appointments',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xff8159a8),
                        child: const Text(
                          'JD',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TabButton(
                    label: 'Upcoming',
                    selected: selectedTab == 0,
                    onTap: () => setState(() => selectedTab = 0),
                  ),
                  _TabButton(
                    label: 'Completed',
                    selected: selectedTab == 1,
                    onTap: () => setState(() => selectedTab = 1),
                  ),
                  _TabButton(
                    label: 'Canceled',
                    selected: selectedTab == 2,
                    onTap: () => setState(() => selectedTab = 2),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Appointment Cards
              if (selectedTab == 1)
                ...appointments.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F3FF),
                        border: Border.all(color: Color(0xFFE0D7F8)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a['date']!,
                            style: const TextStyle(
                              color: Color(0xff8159a8),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Therapist: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: a['therapist']),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Type: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: a['type']),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            a['desc']!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                side: const BorderSide(
                                  color: Color(0xff8159a8),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                'View Details',
                                style: TextStyle(color: Color(0xff8159a8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (selectedTab != 1)
                Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Text(
                    selectedTab == 0
                        ? 'No upcoming appointments.'
                        : 'No canceled appointments.',
                    style: const TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xff8159a8) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
