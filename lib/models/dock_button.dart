import 'package:flutter/material.dart';

class DockButton {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const DockButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  DockButton copyWith({
    IconData? icon,
    String? label,
    Color? color,
    VoidCallback? onTap,
  }) {
    return DockButton(
      icon: icon ?? this.icon,
      label: label ?? this.label,
      color: color ?? this.color,
      onTap: onTap ?? this.onTap,
    );
  }
}