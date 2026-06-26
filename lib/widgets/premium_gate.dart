import 'package:flutter/material.dart';

/// Offline mode: semua fitur unlocked.
class PremiumGate extends StatelessWidget {
  final Widget child;
  final Widget? lockedChild;

  const PremiumGate({super.key, required this.child, this.lockedChild});

  @override
  Widget build(BuildContext context) => child;
}
