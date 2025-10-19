import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';
import 'package:audioplayers/audioplayers.dart';

class RelaxationPage extends StatefulWidget {
  const RelaxationPage({Key? key}) : super(key: key);

  @override
  State<RelaxationPage> createState() => _RelaxationPageState();
}

class _RelaxationPageState extends State<RelaxationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Color primaryColor = const Color(0xFF8159A8);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: const TherapyAppBar(
        title: 'Focus & Relax',
        showBackButton: true,
        backgroundColor: Color(0xFFFAFAFA),
      ),
      bottomNavigationBar: MobileNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/appointments');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/task_dashboard');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/choose_therapist');
          }
        },
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.music_note),
                  text: 'Calm Music',
                ),
                Tab(
                  icon: Icon(Icons.air),
                  text: 'Breathing',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                CalmMusicTab(),
                BreathingExerciseTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Calm Music Tab
class CalmMusicTab extends StatefulWidget {
  const CalmMusicTab({Key? key}) : super(key: key);

  @override
  State<CalmMusicTab> createState() => _CalmMusicTabState();
}

class _CalmMusicTabState extends State<CalmMusicTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final Color primaryColor = const Color(0xFF8159A8);

  late AudioPlayer _audioPlayer;
  int? _playingIndex;
  bool _isPlaying = false;
  PlayerState _playerState = PlayerState.stopped;

  final List<Map<String, dynamic>> _musicTracks = [
    {
      'title': 'Forest Ambience',
      'duration': '10:00',
      'description': 'Peaceful forest sounds with gentle rain',
      'icon': Icons.forest,
      'file': 'assets/audio/forest.mp3',
    },
    {
      'title': 'Ocean Waves',
      'duration': '15:00',
      'description': 'Calming ocean waves on a quiet beach',
      'icon': Icons.waves,
      'file': 'assets/audio/ocean.mp3',
    },
    {
      'title': 'Meditation Bell',
      'duration': '8:00',
      'description': 'Tibetan singing bowls and bells',
      'icon': Icons.self_improvement,
      'file': 'assets/audio/meditation.mp3',
    },
    {
      'title': 'Rain Sounds',
      'duration': '12:00',
      'description': 'Gentle rain on leaves',
      'icon': Icons.water_drop,
      'file': 'assets/audio/rain.mp3',
    },
    {
      'title': 'White Noise',
      'duration': '20:00',
      'description': 'Continuous white noise for focus',
      'icon': Icons.graphic_eq,
      'file': 'assets/audio/whitenoise.mp3',
    },
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _playerState = state;
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Listen to completion
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playingIndex = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(int index) async {
    try {
      // If same track and playing, pause it
      if (_playingIndex == index && _isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      }
      // If same track and paused, resume it
      else if (_playingIndex == index && !_isPlaying) {
        await _audioPlayer.resume();
        setState(() {
          _isPlaying = true;
        });
      }
      // If different track, stop current and play new one
      else {
        await _audioPlayer.stop();
        setState(() {
          _playingIndex = index;
        });

        final audioFile = _musicTracks[index]['file'];
        await _audioPlayer.play(AssetSource(audioFile.replaceFirst('assets/', '')));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Now playing: ${_musicTracks[index]['title']}'),
            backgroundColor: primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing audio: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.8),
                  primaryColor.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.headphones,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Relaxing Sounds',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Choose your perfect ambience',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Available Tracks',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          ..._musicTracks.asMap().entries.map((entry) {
            final index = entry.key;
            final track = entry.value;
            final isCurrentlyPlaying = _playingIndex == index && _isPlaying;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrentlyPlaying
                      ? primaryColor
                      : Colors.grey[200]!,
                  width: isCurrentlyPlaying ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCurrentlyPlaying
                          ? primaryColor.withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      track['icon'],
                      color: isCurrentlyPlaying
                          ? primaryColor
                          : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track['title'],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCurrentlyPlaying
                                ? primaryColor
                                : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          track['description'],
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => _togglePlay(index),
                        icon: Icon(
                          isCurrentlyPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: primaryColor,
                          size: 40,
                        ),
                      ),
                      Text(
                        track['duration'],
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// Breathing Exercise Tab
class BreathingExerciseTab extends StatefulWidget {
  const BreathingExerciseTab({Key? key}) : super(key: key);

  @override
  State<BreathingExerciseTab> createState() => _BreathingExerciseTabState();
}

class _BreathingExerciseTabState extends State<BreathingExerciseTab>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final Color primaryColor = const Color(0xFF8159A8);

  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  Timer? _phaseTimer;
  String _currentPhase = 'Ready to begin';
  int _currentCycle = 0;
  int _totalCycles = 5;
  bool _isBreathingActive = false;

  final List<Map<String, dynamic>> _breathingPatterns = [
    {
      'name': 'Box Breathing',
      'description': '4-4-4-4 pattern - Equal breathing',
      'inhale': 4,
      'hold1': 4,
      'exhale': 4,
      'hold2': 4,
    },
    {
      'name': 'Calm Breathing',
      'description': '4-7-8 pattern - Deep relaxation',
      'inhale': 4,
      'hold1': 7,
      'exhale': 8,
      'hold2': 0,
    },
    {
      'name': 'Energizing Breath',
      'description': '3-0-3-0 pattern - Quick energy',
      'inhale': 3,
      'hold1': 0,
      'exhale': 3,
      'hold2': 0,
    },
  ];

  int _selectedPatternIndex = 0;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _phaseTimer?.cancel();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isBreathingActive = true;
      _currentCycle = 0;
    });
    _runBreathingCycle();
  }

  void _stopBreathing() {
    _phaseTimer?.cancel();
    _breatheController.stop();
    setState(() {
      _isBreathingActive = false;
      _currentPhase = 'Ready to begin';
      _currentCycle = 0;
    });
  }

  void _runBreathingCycle() {
    if (_currentCycle >= _totalCycles) {
      _stopBreathing();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Great job! Breathing exercise completed.'),
          backgroundColor: primaryColor,
        ),
      );
      return;
    }

    final pattern = _breathingPatterns[_selectedPatternIndex];
    int step = 0;

    void nextPhase() {
      if (!_isBreathingActive) return;

      switch (step) {
        case 0: // Inhale
          setState(() {
            _currentPhase = 'Breathe In';
            _currentCycle++;
          });
          _breatheController.forward(from: 0);
          _phaseTimer = Timer(
            Duration(seconds: pattern['inhale']),
            nextPhase,
          );
          break;
        case 1: // Hold 1
          if (pattern['hold1'] > 0) {
            setState(() => _currentPhase = 'Hold');
            _phaseTimer = Timer(
              Duration(seconds: pattern['hold1']),
              nextPhase,
            );
          } else {
            nextPhase();
            return;
          }
          break;
        case 2: // Exhale
          setState(() => _currentPhase = 'Breathe Out');
          _breatheController.reverse();
          _phaseTimer = Timer(
            Duration(seconds: pattern['exhale']),
            nextPhase,
          );
          break;
        case 3: // Hold 2
          if (pattern['hold2'] > 0) {
            setState(() => _currentPhase = 'Hold');
            _phaseTimer = Timer(
              Duration(seconds: pattern['hold2']),
              () {
                step = -1;
                nextPhase();
              },
            );
          } else {
            step = -1;
            nextPhase();
            return;
          }
          break;
        default:
          _runBreathingCycle();
          return;
      }
      step++;
    }

    nextPhase();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breathing Pattern Selection
          const Text(
            'Choose Pattern',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          ..._breathingPatterns.asMap().entries.map((entry) {
            final index = entry.key;
            final pattern = entry.value;
            final isSelected = _selectedPatternIndex == index;

            return GestureDetector(
              onTap: _isBreathingActive
                  ? null
                  : () {
                      setState(() {
                        _selectedPatternIndex = index;
                      });
                    },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? primaryColor : Colors.grey[400]!,
                          width: 2,
                        ),
                        color: isSelected ? primaryColor : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pattern['name'],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? primaryColor
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pattern['description'],
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 32),

          // Breathing Animation Circle
          Center(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _breatheAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 200 * _breatheAnimation.value,
                      height: 200 * _breatheAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            primaryColor.withOpacity(0.8),
                            primaryColor.withOpacity(0.4),
                            primaryColor.withOpacity(0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _currentPhase,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                if (_isBreathingActive)
                  Text(
                    'Cycle $_currentCycle of $_totalCycles',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Control Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isBreathingActive ? _stopBreathing : _startBreathing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isBreathingActive ? Colors.red : primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isBreathingActive ? 'Stop' : 'Start Exercise',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
