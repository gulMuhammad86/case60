import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';

/// Placeholder for the achievements gallery.
class AchievementsPlaceholderScreen extends StatelessWidget {
  const AchievementsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EmptyState(
        title: 'Achievements',
        subtitle: 'Earned badges will appear here as you solve cases.',
        icon: Icons.emoji_events_outlined,
      ),
    );
  }
}