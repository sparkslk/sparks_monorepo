import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';

class BookSessionScreen extends StatefulWidget {
  const BookSessionScreen({Key? key}) : super(key: key);

  @override
  State<BookSessionScreen> createState() => _BookSessionScreenState();
}

class _BookSessionScreenState extends State<BookSessionScreen> {
  int selectedDateIndex = 0;
  int selectedTimeIndex = 1; // 10:00 AM - 11:00 AM
  bool showCalendar = false;

  final dates = [
    {'day': 'Mon', 'date': '22'},
    {'day': 'Tue', 'date': '23'},
    {'day': 'Wed', 'date': '24'},
    {'day': 'Thu', 'date': '25'},
    {'day': 'Fri', 'date': '26'},
  ];

  final timeSlots = [
    '9:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 AM',
    '12:00 AM - 1:00 PM',
    '1:00 PM - 2:00 PM',
    '2:00 PM - 3:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MobileNavBar(currentIndex: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.light_mode_outlined, color: Colors.black),
                  const Text(
                    'Book a Session',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 18),
              // Therapist Card
              const Text(
                'Your Therapist',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3FF),
                  border: Border.all(color: Color(0xFFE0D7F8)),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/women/44.jpg',
                      ),
                      radius: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text(
                                'Dr. Evelyn Reed',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.star,
                                color: Color(0xFFFFB300),
                                size: 18,
                              ),
                              Text(
                                '4.9',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Cognitive Behavioral Therapy',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Rs.3000 per session',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Select Date
              const Text(
                'Select Date',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (int i = 0; i < dates.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDateIndex = i;
                          });
                        },
                        child: Container(
                          width: 56,
                          decoration: BoxDecoration(
                            color: selectedDateIndex == i
                                ? const Color(0xff8159a8)
                                : Colors.white,
                            border: Border.all(
                              color: selectedDateIndex == i
                                  ? const Color(0xff8159a8)
                                  : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              Text(
                                dates[i]['day']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: selectedDateIndex == i
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dates[i]['date']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: selectedDateIndex == i
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showCalendar = !showCalendar;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          'View Calendar',
                          style: TextStyle(
                            color: Color(0xff8159a8),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Icon(
                          showCalendar ? Icons.expand_less : Icons.expand_more,
                          color: Color(0xff8159a8),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showCalendar) ...[
                const SizedBox(height: 10),
                // Simple Calendar (not interactive for brevity)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'June 2025',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Mon'),
                          Text('Tue'),
                          Text('Wed'),
                          Text('Thu'),
                          Text('Fri'),
                          Text('Sat'),
                          Text('Sun'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: List.generate(30, (i) {
                          final isSelected = i == 18; // 19th
                          return Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xff8159a8)
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? Color(0xff8159a8)
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              // Available Time Slots
              Text(
                'Available Time Slots ${dates[selectedDateIndex]['day']} ${dates[selectedDateIndex]['date']}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(timeSlots.length, (i) {
                  final isSelected = selectedTimeIndex == i;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTimeIndex = i;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xff8159a8)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xff8159a8)
                              : Colors.grey.shade400,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        timeSlots[i],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              // Booking Summary
              const Text(
                'Booking Summary',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _SessionDetailRow(
                      label: 'Date:',
                      value:
                          '${dates[selectedDateIndex]['day']} ${dates[selectedDateIndex]['date']}',
                    ),
                    _SessionDetailRow(
                      label: 'Time:',
                      value: timeSlots[selectedTimeIndex],
                    ),
                    const _SessionDetailRow(
                      label: 'Therapist:',
                      value: 'Dr. Evelyn Reed',
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Total Cost:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$120.00',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff8159a8),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff8159a8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Confirm Booking',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _SessionDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
