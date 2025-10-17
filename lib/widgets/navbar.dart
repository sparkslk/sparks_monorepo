import 'package:flutter/material.dart';

class MobileNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const MobileNavBar({Key? key, required this.currentIndex, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Height to accommodate the navbar + margins
      color: Colors.transparent, // Ensure container is transparent
      child: Stack(
        children: [
          Positioned(
            left: 16,
            right: 16,
            bottom: 25,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    spreadRadius: -10,
                    blurRadius: 60,
                    color: Colors.black.withOpacity(.20),
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Icons.home, 'Home', 0, context),
                    _buildNavItem(Icons.calendar_today, 'Tasks', 1, context),
                    _buildNavItem(Icons.lightbulb_outline, 'Keep', 2, context),
                    _buildNavItem(Icons.people_outline, 'Sessions', 3, context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    BuildContext context,
  ) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        // Call the onTap callback if provided
        if (onTap != null) {
          onTap!(index);
          return;
        }

        // Default navigation logic
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/dashboard');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/appointments');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/task_dashboard');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/appointments');
            break;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 12,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xff8159a8).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xff8159a8)
                  : Colors.grey.shade600,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: const Color(0xff8159a8),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
