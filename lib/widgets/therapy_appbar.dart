import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class TherapyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double height;
  final Color backgroundColor;

  const TherapyAppBar({
    Key? key,
    this.title = 'Therapists',
    this.showBackButton = false,
    this.onBackPressed,
    this.height = 56,
    this.backgroundColor = const Color(0xFFF8F7FC),
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height + 24); // height + status bar padding

  @override
  State<TherapyAppBar> createState() => _TherapyAppBarState();
}

class _TherapyAppBarState extends State<TherapyAppBar> {
  String? _userImage;
  String? _userName;
  Timer? _logoutTimer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _logoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('user_data');
      if (userDataStr != null && userDataStr.isNotEmpty) {
        final userData = jsonDecode(userDataStr);
        if (mounted) {
          setState(() {
            _userImage = userData['image'];
            _userName = userData['name'];
          });
        }
      }
    } catch (e) {
      // Silent fail - will use default avatar
    }
  }

  void _startLogoutTimer() {
    _logoutTimer?.cancel();
    _logoutTimer = Timer(const Duration(seconds: 5), () {
      _logout();
    });
  }

  void _cancelLogoutTimer() {
    _logoutTimer?.cancel();
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF8159A8),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error logging out'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          // Left Icon (Emergency or Back Button)
          widget.showBackButton
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                    size: 24,
                  ),
                  onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
                  tooltip: 'Back',
                )
              : IconButton(
                  icon: const Icon(
                    Icons.emergency,
                    color: Color(0xff8159a8),
                    size: 28,
                  ),
                  onPressed: () {
                    // TODO: Add emergency/crisis support action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Emergency support feature coming soon'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Emergency Support',
                ),
          // Title (center)
          Expanded(
            child: Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                  size: 24,
                ),
                onPressed: () {
                  // TODO: Navigate to notifications page when implemented
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications feature coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Notifications',
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                onLongPressStart: (details) {
                  _startLogoutTimer();
                },
                onLongPressEnd: (details) {
                  _cancelLogoutTimer();
                },
                onLongPressCancel: () {
                  _cancelLogoutTimer();
                },
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xff8159a8),
                  backgroundImage: _userImage != null && _userImage!.isNotEmpty
                      ? (_userImage!.startsWith('data:image/')
                          ? MemoryImage(base64Decode(_userImage!.split(',')[1]))
                          : NetworkImage(_userImage!)) as ImageProvider
                      : null,
                  child: _userImage == null || _userImage!.isEmpty
                      ? Text(
                          _userName?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ],
          ),
        ),
      ),
    );
  }
}
