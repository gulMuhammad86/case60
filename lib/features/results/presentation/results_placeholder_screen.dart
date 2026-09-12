import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';

/// Placeholder for the results/explanation screen.
class ResultsPlaceholderScreen extends StatelessWidget {
  const ResultsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EmptyState(
        title: 'Case Results',
        subtitle: 'Results will appear here after solving a case.',
        icon: Icons.verified_outlined,
      ),
    );
  }
}