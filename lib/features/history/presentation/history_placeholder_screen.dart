import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';

/// Placeholder for the case history / log of past solved mysteries.
class HistoryPlaceholderScreen extends StatelessWidget {
  const HistoryPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EmptyState(
        title: 'Case History',
        subtitle: 'Your solved cases will be logged here.',
        icon: Icons.folder_open,
      ),
    );
  }
}