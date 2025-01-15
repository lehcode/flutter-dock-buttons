import 'package:flutter/material.dart';
import 'package:dock_animate/widgets/dock.dart';
import 'package:dock_animate/models/dock_button.dart';
import 'package:dock_animate/widgets/desktop_widget.dart';

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

class AppHomePage extends StatefulWidget {
  const AppHomePage({super.key});

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  // Make _dockButtons non-final so we can modify it
  List<DockButton> _dockButtons = [
    const DockButton(
      icon: Icons.home,
      label: 'Home',
      color: Color(0xFF007AFF),
    ),
    const DockButton(
      icon: Icons.person,
      label: 'Profile',
      color: Color(0xFF34C759),
    ),
    const DockButton(
      icon: Icons.settings,
      label: 'Settings',
      color: Color(0xFFFF9500),
    ),
    const DockButton(
      icon: Icons.message,
      label: 'Messages',
      color: Colors.purple,
    ),
    const DockButton(
      icon: Icons.notifications,
      label: 'Notifications',
      color: Colors.red,
    ),
  ];

  void _onButtonMovedToDesktop(DockButton button) {
    setState(() {
      // Find and remove the button from dock
      _dockButtons = _dockButtons.where((b) => 
        b.icon != button.icon || 
        b.label != button.label || 
        b.color != button.color
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DesktopWidget(
        onButtonDropped: _onButtonMovedToDesktop,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Center(
                child: Dock(
                  buttons: _dockButtons,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}