import 'package:flutter/material.dart';

class TherapyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  const TherapyAppBar({Key? key, this.height = 56}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Emergency Icon (left)
          IconButton(
            icon: const Icon(
              Icons.emergency,
              color: Colors.black54,
              size: 28,
            ),
            onPressed: () {
              // TODO: Add emergency action
            },
            tooltip: 'Emergency',
          ),
          // Title (center)
          Expanded(
            child: Center(
              child: Text(
                'Therapists',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: 1.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Notification and Profile Icons (right)
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.black54,
                ),
                onPressed: () {
                  // TODO: Add notification action
                },
                tooltip: 'Notifications',
              ),
              const SizedBox(width: 4),
              const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                  'https://randomuser.me/api/portraits/men/24.jpg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
