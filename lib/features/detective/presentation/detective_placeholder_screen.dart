import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';

/// Placeholder for the detective profile / XP / streak screen.
class DetectivePlaceholderScreen extends StatelessWidget {
  const DetectivePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EmptyState(
        title: 'Detective Profile',
        subtitle: 'Rank, XP and streak will appear here.',
        icon: Icons.badge_outlined,
      ),
    );
  }
}