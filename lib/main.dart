import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00E5FF),
          secondary: const Color(0xFF1A1A1A),
        ),
      ),
      home: const StopwatchScreen(),
    );
  }
}

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  Timer? _timer;
  int _milliseconds = 0;
  bool _isRunning = false;
  List<int> _laps = [];

  void _addLap() {
    if (_isRunning) {
      setState(() {
        _laps.insert(0, _milliseconds);
      });
    }
  }

  void _startStop() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        setState(() {
          _milliseconds += 10;
        });
      });
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _milliseconds = 0;
      _isRunning = false;
      _laps.clear();
    });
  }

  String _formatTime() {
    int minutes = (_milliseconds ~/ 60000);
    int seconds = ((_milliseconds % 60000) ~/ 1000);
    int milliseconds = ((_milliseconds % 1000) ~/ 10);

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:${milliseconds.toString().padLeft(2, '0')}';
  }

  String _formatLapTime(int ms) {
    int minutes = (ms ~/ 60000);
    int seconds = ((ms % 60000) ~/ 1000);
    int milliseconds = ((ms % 1000) ~/ 10);

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:${milliseconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.space) {
          _startStop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                const Color(0xFF1A1A1A).withOpacity(0.3),
                const Color(0xFF0A0A0A),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 1),

                // Stopwatch Display
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.1),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(60),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A1A1A).withOpacity(0.5),
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                            color: const Color(0xFF00E5FF),
                            shadows: [
                              Shadow(
                                color: const Color(0xFF00E5FF).withOpacity(0.5),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'MIN : SEC : MS',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // Lap Times Display
                if (_laps.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _laps.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0A0A).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF00E5FF).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.flag_rounded,
                                    color: const Color(
                                      0xFF00E5FF,
                                    ).withOpacity(0.6),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Lap ${_laps.length - index}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xFF666666),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                _formatLapTime(_laps[index]),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: const Color(0xFF00E5FF),
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                const Spacer(flex: 1),

                // Control Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Reset Button
                      _buildControlButton(
                        icon: Icons.refresh_rounded,
                        label: 'RESET',
                        onPressed: _reset,
                        color: const Color(0xFF666666),
                      ),

                      // Lap Button (Flag)
                      _buildControlButton(
                        icon: Icons.flag_rounded,
                        label: 'LAP',
                        onPressed: _addLap,
                        color: _isRunning
                            ? const Color(0xFFFFB300)
                            : const Color(0xFF666666),
                      ),

                      // Start/Pause Button
                      _buildControlButton(
                        icon: _isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        label: _isRunning ? 'PAUSE' : 'START',
                        onPressed: _startStop,
                        color: const Color(0xFF00E5FF),
                        isPrimary: true,
                      ),

                      // Stop Button
                      _buildControlButton(
                        icon: Icons.stop_rounded,
                        label: 'STOP',
                        onPressed: () {
                          if (_isRunning) {
                            _startStop();
                          }
                          _reset();
                        },
                        color: const Color(0xFF666666),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              splashColor: color.withOpacity(0.3),
              child: Container(
                width: isPrimary ? 80 : 64,
                height: isPrimary ? 80 : 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A1A1A).withOpacity(0.6),
                  border: Border.all(
                    color: color.withOpacity(isPrimary ? 0.6 : 0.3),
                    width: isPrimary ? 2 : 1,
                  ),
                ),
                child: Icon(icon, color: color, size: isPrimary ? 40 : 28),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: color.withOpacity(0.7),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}
