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

  /// Creates a copy of this [DockButton] but with the given fields replaced with the new values.
  ///
  /// [icon], [label], [color], and [onTap] can be null if they are not to be changed.
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
