import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/match_model.dart';
import 'status_badge.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: match.isLive
              ? AppTheme.liveRed.withValues(alpha: 0.3)
              : AppTheme.cardBorder,
          width: match.isLive ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.matchDetails, arguments: match);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status Badge & Competition / Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(
                    status: match.normalizedStatus,
                    isLive: match.isLive,
                    isUpcoming: match.isUpcoming,
                    isFinished: match.isFinished,
                  ),
                  Row(
                    children: [
                      if (match.competition.emblem != null && match.competition.emblem!.isNotEmpty) ...[
                        _buildCrest(match.competition.emblem, size: 16),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        match.competition.name.isNotEmpty
                            ? match.competition.name
                            : (match.matchDate.isNotEmpty ? match.matchDate : 'TBD'),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Teams & Scores Row
              Row(
                children: [
                  // Team A (Home Team)
                  Expanded(
                    child: _buildTeamColumn(
                      teamName: match.teamA,
                      score: match.scoreA,
                      overs: match.oversA,
                      logoUrl: match.teamALogo,
                      isUpcoming: match.isUpcoming,
                      alignment: CrossAxisAlignment.start,
                    ),
                  ),

                  // Center "VS" Pill / Minute
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Text(
                      match.isLive && match.minute != null
                          ? "${match.minute}'"
                          : 'VS',
                      style: TextStyle(
                        color: match.isLive && match.minute != null
                            ? AppTheme.liveRed
                            : AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Team B (Away Team)
                  Expanded(
                    child: _buildTeamColumn(
                      teamName: match.teamB,
                      score: match.scoreB,
                      overs: match.oversB,
                      logoUrl: match.teamBLogo,
                      isUpcoming: match.isUpcoming,
                      alignment: CrossAxisAlignment.end,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 1, color: AppTheme.dividerColor),
              const SizedBox(height: 12),

              // Match Summary Note (if available)
              if (match.description != null && match.description!.isNotEmpty) ...[
                Text(
                  match.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.accentGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Venue and Details Link
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            match.venue != null && match.venue!.isNotEmpty
                                ? match.venue!
                                : 'Stadium',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Row(
                    children: [
                      Text(
                        'Details',
                        style: TextStyle(
                          color: AppTheme.accentBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppTheme.accentBlue,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamColumn({
    required String teamName,
    required String score,
    String? overs,
    String? logoUrl,
    required bool isUpcoming,
    required CrossAxisAlignment alignment,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: alignment == CrossAxisAlignment.end
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (alignment == CrossAxisAlignment.start) ...[
              _buildCrest(logoUrl, fallbackName: teamName),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                teamName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (alignment == CrossAxisAlignment.end) ...[
              const SizedBox(width: 8),
              _buildCrest(logoUrl, fallbackName: teamName),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isUpcoming ? '-' : score,
          style: TextStyle(
            color: isUpcoming ? AppTheme.textMuted : AppTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        if (!isUpcoming && overs != null && overs.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            '($overs ov)',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCrest(String? url, {double size = 28, String? fallbackName}) {
    if (url != null && url.isNotEmpty && !url.endsWith('.svg')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (context, url) => SizedBox(
          width: size,
          height: size,
          child: const Center(
            child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.accentBlue),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallbackAvatar(fallbackName ?? 'T', size),
      );
    }
    return _buildFallbackAvatar(fallbackName ?? 'T', size);
  }

  Widget _buildFallbackAvatar(String name, double size) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'T';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.cardBorder, width: 1),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: AppTheme.accentBlue,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.45,
          ),
        ),
      ),
    );
  }
}
