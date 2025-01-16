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
  /// Builds the main application widget.
  ///
  /// - [context] is the build context in which the widget is built.
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
  bool _isDisposed = false;

  @override
  void dispose() {
    // Clear dock buttons list
    _dockButtons.clear();
    
    // Mark as disposed
    _isDisposed = true;
    
    super.dispose();
  }

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

  @override
  /// Builds the main application widget.
  ///
  /// - [context] is the build context in which the widget is built.
  ///
  /// Returns a [Scaffold] widget with a [DesktopWidget] as its body. The
  /// [DesktopWidget] contains a [Stack] with a [Dock] widget at the bottom.
  Widget build(BuildContext context) {
    return Scaffold(
      body: DesktopWidget(
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