import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/challenge.dart';
import '../providers/challenge_provider.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/design_tokens.dart';
import 'challenge_detail_screen.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  Future<void> _showResetDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.of(context, 'titleResetChallenge')),
        content: Text(AppStrings.of(context, 'descResetChallenge')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: Text(AppStrings.of(context, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              context.read<ChallengeProvider>().resetChallenges();
              Navigator.pop(dialogContext);
            },
            child: Text(
              AppStrings.of(context, 'btnReset'), 
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ChallengeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.challenges.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final challenges = provider.challenges;
        
        final sectionTitleStyle = TextStyle(
          letterSpacing: 1.5,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        );

        return RefreshIndicator(
          onRefresh: () => _showResetDialog(context),
          edgeOffset: 110,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 110, 20, 130),
            children: [
              Text(AppStrings.of(context, 'dailyChallenge'), style: sectionTitleStyle),
              const SizedBox(height: 20),
              if (challenges.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(
                      AppStrings.of(context, 'noChallenges'),
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  ),
                )
              else
                ...challenges
                    .where((c) => c.status != ChallengeStatus.locked)
                    .map((challenge) => Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: _buildChallengeCard(context, challenge, isDark, theme),
                        )),
              const SizedBox(height: 25),
              Text(AppStrings.of(context, 'specialEvents'), style: sectionTitleStyle),
              const SizedBox(height: 15),
              _buildEventCard(context, isDark),
              const SizedBox(height: 25),
              Text(AppStrings.of(context, 'lockedChallenges'), style: sectionTitleStyle),
              const SizedBox(height: 15),
              ...challenges
                  .where((c) => c.status == ChallengeStatus.locked)
                  .map((challenge) => Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _buildChallengeCard(context, challenge, isDark, theme),
                      )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChallengeCard(BuildContext context, Challenge challenge, bool isDark, ThemeData theme) {
    bool isLocked = challenge.status == ChallengeStatus.locked;
    bool isDone = challenge.status == ChallengeStatus.done;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeDetailScreen(challenge: challenge),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Opacity(
        opacity: isLocked ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppDesignTokens.msgBotBgDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLocked
                  ? (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.05))
                  : (isDone 
                      ? Colors.green.withValues(alpha: isDark ? 0.3 : 0.5) 
                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03))),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              if (!isLocked && !isDone && isDark)
                BoxShadow(
                  color: challenge.color.withValues(alpha: 0.05),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            AppStrings.of(context, challenge.title),
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 15,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isDone) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        ],
                        if (isLocked) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.lock_outline_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.3), size: 16),
                        ]
                      ],
                    ),
                  ),
                  Text(
                    challenge.reward,
                    style: TextStyle(
                      color: isDark ? challenge.color : challenge.color.withRed((challenge.color.r * 255.0).round().clamp(0, 255) - 20).withGreen((challenge.color.g * 255.0).round().clamp(0, 255) - 20), 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.of(context, challenge.description),
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6), 
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: challenge.progress,
                  backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  color: isLocked 
                      ? (isDark ? Colors.white24 : Colors.black26) 
                      : (isDark ? challenge.color : challenge.color.withValues(alpha: 0.8)),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, bool isDark) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: isDark ? 0.3 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.emoji_events_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.of(context, 'weekendHackathon'),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.of(context, 'hackathonDesc'),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6366F1),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(AppStrings.of(context, 'joinNow'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
