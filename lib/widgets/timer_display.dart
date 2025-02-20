import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final int secondsRemaining;
  final bool isWorkTime;
  final int focusDuration;
  final int shortBreakDuration;

  const TimerDisplay({
    Key? key,
    required this.secondsRemaining,
    required this.isWorkTime,
    required this.focusDuration,
    required this.shortBreakDuration,
  }) : super(key: key);

  /// Formats time in MM:SS format
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    seconds %= 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: CircularProgressIndicator(
            value: secondsRemaining /
                (isWorkTime ? focusDuration : shortBreakDuration),
            strokeWidth: 15,
            color: isWorkTime ? Color(0xFF00A676) : Color(0xFF77A6B6), // Vibrant Emerald Green for work time, Soft Green for break
            backgroundColor: Color(0xFFE0E0E0), // Neutral Gray for background
          ),
        ),
        Text(
          _formatTime(secondsRemaining),
          style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Color(0xFF202124), // Dark Charcoal Black for text
          ),
        ),
      ],
    );
  }
}