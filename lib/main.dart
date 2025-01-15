import 'package:flutter/material.dart';
import 'package:dock_animate/widgets/dock.dart';
import 'package:dock_animate/models/dock_button.dart';

void main() {
  runApp(const DockApp());
}

class DockApp extends StatelessWidget {
  const DockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Dock',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AppHomePage(),
    );
  }
}

class AppHomePage extends StatelessWidget {
  const AppHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: Dock(
                buttons: const [
                  DockButton(
                    icon: Icons.home,
                    label: 'Home',
                    color: Color(0xFF007AFF),
                  ),
                  DockButton(
                    icon: Icons.person,
                    label: 'Profile',
                    color: Color(0xFF34C759),
                  ),
                  DockButton(
                    icon: Icons.settings,
                    label: 'Settings',
                    color: Color(0xFFFF9500),
                  ),
                  DockButton(
                    icon: Icons.message,
                    label: 'Messages',
                    color: Colors.purple,
                  ),
                  DockButton(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}