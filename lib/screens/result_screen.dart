import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/analysis_result.dart';
import '../theme/app_theme.dart';
import '../widgets/score_ring.dart';
import '../widgets/risk_badge.dart';
import '../widgets/red_flag_card.dart';

class ResultScreen extends StatelessWidget {
  final AnalysisResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final riskColor = AppColors.riskColor(result.riskLevel);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'Analysis Result',
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () => _shareAnalysis(context),
                tooltip: 'Share analysis',
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Score Hero Section
                Card.filled(
                  color: colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 24),
                    child: Column(
                      children: [
                        ScoreRing(score: result.manipulationScore),
                        const SizedBox(height: 16),
                        Text(
                          'Manipulation Score',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        RiskBadge(riskLevel: result.riskLevel, large: true),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 12),

                // Risk Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: riskColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(AppColors.riskIcon(result.riskLevel),
                          color: riskColor, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _riskMessage(result.riskLevel),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: riskColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideX(begin: 0.05, end: 0),

                const SizedBox(height: 20),

                // Summary
                _buildSectionCard(
                  context,
                  icon: Icons.summarize_rounded,
                  title: 'Summary',
                  delay: 300,
                  child: Text(
                    result.summary,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                ),

                // Key Points
                if (result.keyPoints.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    context,
                    icon: Icons.key_rounded,
                    title: 'Key Points',
                    delay: 400,
                    child: Column(
                      children: [
                        for (int i = 0; i < result.keyPoints.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    result.keyPoints[i],
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                // Red Flags
                if (result.flags.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: Row(
                      children: [
                        Icon(Icons.flag_rounded,
                            color: AppColors.riskColor('danger'), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Red Flags (${result.flags.length})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 400.ms),
                  ...result.flags.asMap().entries.map(
                        (entry) => RedFlagCard(
                          flag: entry.value,
                          index: entry.key,
                        )
                            .animate()
                            .fadeIn(
                                delay: (550 + entry.key * 100).ms,
                                duration: 400.ms)
                            .slideX(begin: 0.05, end: 0),
                      ),
                ],

                // Hidden Meanings
                if (result.hiddenMeanings.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.visibility_off_rounded,
                                  color: colorScheme.primary, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Hidden Meanings',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ...result.hiddenMeanings.map(
                            (meaning) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Icon(
                                      Icons.remove_red_eye_rounded,
                                      size: 16,
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      meaning,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 650.ms, duration: 400.ms)
                      .slideY(begin: 0.05, end: 0),
                ],

                // Tone Analysis
                if (result.toneAnalysis.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    context,
                    icon: Icons.psychology_rounded,
                    title: 'Tone Analysis',
                    delay: 700,
                    child: Text(
                      result.toneAnalysis,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
                ],

                // Suggested Response
                if (result.suggestedResponse.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Card.filled(
                    color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_rounded,
                                  color: colorScheme.secondary, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Suggested Response',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.copy_rounded,
                                    size: 20,
                                    color: colorScheme.onSurfaceVariant),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Clipboard.setData(ClipboardData(
                                      text: result.suggestedResponse));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Suggested response copied!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                tooltip: 'Copy response',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            result.suggestedResponse,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 400.ms)
                      .slideY(begin: 0.05, end: 0),
                ],

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(
                              ClipboardData(text: result.toShareText()));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Analysis copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('Copy'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _shareAnalysis(context),
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 400.ms),

                // Safe celebration
                if (result.riskLevel.toLowerCase() == 'safe') ...[
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.riskColor('safe')
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('\u{1F389}',
                              style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 10),
                          Text(
                            'Looking good! This text is safe.',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.riskColor('safe'),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 600.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutBack,
                      ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int delay,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card.filled(
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: 400.ms)
        .slideY(begin: 0.05, end: 0);
  }

  String _riskMessage(String level) {
    switch (level.toLowerCase()) {
      case 'safe':
        return 'This text appears to be straightforward and transparent.';
      case 'caution':
        return 'Some elements deserve closer attention. Read carefully.';
      case 'warning':
        return 'Significant concerns detected. Proceed with caution.';
      case 'danger':
        return 'High manipulation detected. Be very careful with this text.';
      default:
        return 'Analysis complete.';
    }
  }

  void _shareAnalysis(BuildContext context) {
    HapticFeedback.mediumImpact();
    Share.share(result.toShareText(), subject: 'Contextify Analysis');
  }
}
