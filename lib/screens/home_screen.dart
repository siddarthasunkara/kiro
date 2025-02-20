import 'package:flutter/material.dart';
import 'pomodoro_screen.dart';  // Ensure PomodoroApp() is defined in 'pomodoro_screen.dart'
import 'eisenhower_screen.dart'; // Ensure EisenhowerMatrixScreen() is defined in 'eisenhower_screen.dart'
import 'time_blocking_scheduler.dart'; // Ensure TimeBlockingScreen() is defined in 'time_blocking_scheduler.dart'
import 'habit_tracker_screen.dart'; // Ensure HabitTrackerScreen() is defined in 'habit_tracker_screen.dart'

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of screens for navigation
  List<Widget> _screens = <Widget>[
    HomeScreenContent(), // Default content screen
    PomodoroApp(), // Ensure PomodoroApp() is defined in 'pomodoro_screen.dart'
    EisenhowerMatrixScreen(), // Ensure EisenhowerMatrixScreen() is defined in 'eisenhower_screen.dart'
    TimeBlockingScreen(), // Ensure TimeBlockingScreen() is defined in 'time_blocking_scheduler.dart'
    HabitTrackerScreen(), // Ensure HabitTrackerScreen() is defined in 'habit_tracker_screen.dart'
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kiro', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1A1E3B), // Deep Navy Blue for AppBar
        elevation: 0,
      ),
      body: Container(
        color: Color(0xFFF8F8F8), // Soft Warm Gray background
        child: _screens[_selectedIndex], // Dynamically show the selected screen
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF1A1E3B), // Deep Navy Blue for BottomNavigationBar
        unselectedItemColor: Color(0xFFD1D1D1), // Neutral Cool Gray for unselected items
        selectedItemColor: Color(0xFF00A676), // Vibrant Emerald Green for selected item
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Pomodoro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Matrix',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Time Blocking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Habits',
          ),
        ],
      ),
    );
  }
}

// Home screen content with an overview dashboard
class HomeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Motivational Quotes
    List<String> motivationalQuotes = [
      "The secret of getting ahead is getting started.",
      "Success is the sum of small efforts, repeated day in and day out.",
      "Don’t watch the clock; do what it does. Keep going.",
      "Success usually comes to those who are too busy to be looking for it.",
    ];

    // Select a random motivational quote
    String randomQuote = motivationalQuotes[DateTime.now().second % motivationalQuotes.length];

    return SingleChildScrollView( // Wrap the Column in a SingleChildScrollView
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Motivational Quote Section
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Color(0xFF5F4B8B), // Muted Purple background for motivational quote
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "💡 Today's Motivation 💡",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "\"$randomQuote\"",
                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          // Other Home Screen Content
          Text(
            'Welcome to Kiro!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1E3B)), // Deep Navy Blue
          ),
          SizedBox(height: 20),
          Text(
            'Manage your tasks, track your time, and improve your productivity.',
            style: TextStyle(fontSize: 16, color: Color(0xFF202124)), // Dark Charcoal Black
          ),
          SizedBox(height: 30),
          // Features Section
          Text(
            'Features:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1E3B)), // Deep Navy Blue
          ),
          SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeatureItem('🕒 Pomodoro Timer: Boost your productivity with focused work sessions.'),
              _buildFeatureItem('📊 Eisenhower Matrix: Prioritize your tasks effectively.'),
              _buildFeatureItem('📅 Time Blocking: Schedule your day for maximum efficiency.'),
              _buildFeatureItem('📈 Habit Tracker: Build and maintain good habits.'),
            ],
          ),
          SizedBox(height: 20),
          // Additional Information
          Text(
            'Tips for Success:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1E3B)), // Deep Navy Blue
          ),
          SizedBox(height: 10),
          Text(
            '1. Set clear goals for each session.\n'
                '2. Take regular breaks to maintain focus.\n'
                '3. Review your progress at the end of the day.\n'
                '4. Stay consistent and adjust your strategies as needed.',
            style: TextStyle(fontSize: 16, color: Color(0xFF202124)), // Dark Charcoal Black
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(Icons.check, color: Color(0xFF00A676)), // Vibrant Emerald Green for check icon
          SizedBox(width: 10),
          Expanded(child: Text(feature, style: TextStyle(fontSize: 16, color: Color(0xFF202124)))), // Dark Charcoal Black
        ],
      ),
    );
  }
}