import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/match_model.dart';
import '../controllers/match_details_controller.dart';
import '../../home/widgets/status_badge.dart';

class MatchDetailsView extends GetView<MatchDetailsController> {
  const MatchDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Match Details'),
        actions: [
          Obx(() {
            final currentMatch = controller.match.value;
            if (currentMatch == null) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.edit_note_rounded),
              tooltip: 'Update Score in Admin',
              onPressed: () {
                Get.toNamed(AppRoutes.admin, arguments: currentMatch);
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.match.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accentBlue),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value,
              style: const TextStyle(color: AppTheme.liveRed),
            ),
          );
        }

        final match = controller.match.value;
        if (match == null) {
          return const Center(
            child: Text(
              'Match details not available',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Scoreboard Card
              _buildScoreboardCard(match),
              const SizedBox(height: 16),

              // Match Info Card
              _buildInfoCard(match),
              const SizedBox(height: 16),

              // Real-time Status Card
              _buildRealtimeNoticeCard(match),
              const SizedBox(height: 24),

              // Quick Action Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Get.toNamed(AppRoutes.admin, arguments: match);
                },
                icon: const Icon(Icons.edit_calendar_rounded),
                label: const Text(
                  'Update Score & Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildScoreboardCard(MatchModel match) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: match.isLive
              ? AppTheme.liveRed.withValues(alpha: 0.3)
              : AppTheme.cardBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: match.isLive
                ? AppTheme.liveRed.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Status Badge
          StatusBadge(
            status: match.normalizedStatus,
            isLive: match.isLive,
            isUpcoming: match.isUpcoming,
            isFinished: match.isFinished,
          ),
          const SizedBox(height: 20),

          // Teams and Scores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Team A
              Expanded(
                child: Column(
                  children: [
                    _buildTeamAvatar(match.teamA, logoUrl: match.teamALogo),
                    const SizedBox(height: 10),
                    Text(
                      match.teamA,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      match.isUpcoming ? '-' : match.scoreA,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (!match.isUpcoming && match.oversA != null)
                      Text(
                        '(${match.oversA} ov)',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

              // VS divider / Minute
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Text(
                  match.isLive && match.minute != null ? "${match.minute}'" : 'VS',
                  style: TextStyle(
                    color: match.isLive && match.minute != null
                        ? AppTheme.liveRed
                        : AppTheme.textMuted,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),

              // Team B
              Expanded(
                child: Column(
                  children: [
                    _buildTeamAvatar(match.teamB, logoUrl: match.teamBLogo),
                    const SizedBox(height: 10),
                    Text(
                      match.teamB,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      match.isUpcoming ? '-' : match.scoreB,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (!match.isUpcoming && match.oversB != null)
                      Text(
                        '(${match.oversB} ov)',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          if (match.description != null && match.description!.isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.cardBackgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                match.description!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.accentGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamAvatar(String teamName, {String? logoUrl, double size = 56}) {
    if (logoUrl != null && logoUrl.isNotEmpty && !logoUrl.endsWith('.svg')) {
      return CachedNetworkImage(
        imageUrl: logoUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentBlue),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallbackAvatar(teamName, size),
      );
    }
    return _buildFallbackAvatar(teamName, size);
  }

  Widget _buildFallbackAvatar(String teamName, double size) {
    final initial = teamName.isNotEmpty ? teamName[0].toUpperCase() : 'T';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentBlue.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: AppTheme.accentBlue,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.42,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(MatchModel match) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Match Information',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (match.competition.name.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.emoji_events_outlined,
              label: 'Competition',
              value: match.competition.name,
            ),
            const Divider(height: 20, color: AppTheme.dividerColor),
          ],
          _buildInfoRow(
            icon: Icons.location_on_rounded,
            label: 'Venue',
            value: match.venue != null && match.venue!.isNotEmpty ? match.venue! : 'Stadium',
          ),
          const Divider(height: 20, color: AppTheme.dividerColor),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: match.matchDate.isNotEmpty ? match.matchDate : 'TBD',
          ),
          const Divider(height: 20, color: AppTheme.dividerColor),
          _buildInfoRow(
            icon: Icons.sports_score_rounded,
            label: 'Status',
            value: match.normalizedStatus,
            valueColor: match.isLive
                ? AppTheme.liveRed
                : (match.isFinished ? AppTheme.accentGreen : AppTheme.upcomingOrange),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textMuted),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRealtimeNoticeCard(MatchModel match) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: const Row(
        children: [
          Icon(Icons.bolt_rounded, color: AppTheme.accentBlue, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Real-time Firestore listener active. Scores update instantly.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
