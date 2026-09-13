import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../data/history_provider.dart';
import '../domain/history_entry.dart';
import 'widgets/history_card.dart';

/// The log of every case attempt, newest first.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  static const double _contentMaxWidth = 600;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<HistoryEntry> entries = ref.watch(historyProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppColors.backgroundElevated, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => context.go(AppRoute.home.path),
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.textSecondary,
                      tooltip: 'Back to HQ',
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'CASE HISTORY',
                      style: AppTypography.headline.copyWith(
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SectionHeader(title: 'CASE LOG', kicker: 'ALL ATTEMPTS'),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: entries.isEmpty
                    ? const EmptyState(
                        title: 'No Cases Yet',
                        subtitle: 'Solved (or attempted) cases will be logged here.',
                        icon: Icons.folder_open,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.xl,
                        ),
                        itemCount: entries.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (BuildContext context, int index) {
                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: HistoryScreen._contentMaxWidth,
                              ),
                              child: HistoryCard(entry: entries[index]),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}