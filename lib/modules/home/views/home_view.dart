import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/home_controller.dart';
import '../widgets/match_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.sports_soccer_rounded,
                color: AppTheme.accentBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Live Scores'),
            const SizedBox(width: 8),
            // Live indicator pill in AppBar
            Obx(() {
              if (controller.liveCount > 0) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.liveRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.liveRed, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.liveRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.liveCount} LIVE',
                        style: const TextStyle(
                          color: AppTheme.liveRed,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        actions: [
          // API Sync Action Button
          Obx(() {
            return IconButton(
              tooltip: 'Sync with football-data.org API',
              icon: controller.isSyncing.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.accentBlue,
                      ),
                    )
                  : const Icon(Icons.sync_rounded, color: AppTheme.accentBlue),
              onPressed: controller.isSyncing.value
                  ? null
                  : () => controller.syncFromApi(),
            );
          }),
          IconButton(
            tooltip: 'Admin / Score Updates',
            icon: const Icon(Icons.tune_rounded, color: AppTheme.textPrimary),
            onPressed: () => Get.toNamed(AppRoutes.admin),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.accentBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text(
          'Score Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => Get.toNamed(AppRoutes.admin),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          _buildFilterBar(),

          // Main Match List with Pull-to-Refresh
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allMatches.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentBlue),
                );
              }

              if (controller.errorMessage.value.isNotEmpty && controller.allMatches.isEmpty) {
                return _buildErrorState();
              }

              final matches = controller.filteredMatches;
              if (matches.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: AppTheme.accentBlue,
                backgroundColor: AppTheme.cardBackground,
                onRefresh: () => controller.syncFromApi(),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    return MatchCard(match: matches[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        return ListView(
          scrollDirection: Axis.horizontal,
          children: controller.filterOptions.map((filter) {
            final isSelected = controller.selectedFilter.value == filter;
            int? count;
            if (filter == 'Live') count = controller.liveCount;
            if (filter == 'Upcoming') count = controller.upcomingCount;
            if (filter == 'Finished') count = controller.finishedCount;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(filter),
                    if (count != null && count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : AppTheme.cardBackgroundLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : (filter == 'Live'
                                    ? AppTheme.liveRed
                                    : AppTheme.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                onSelected: (_) => controller.setFilter(filter),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBackgroundLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: const Icon(
                Icons.sports_soccer,
                size: 48,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No ${controller.selectedFilter.value != 'All' ? controller.selectedFilter.value : ''} Matches Found',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fetch live fixtures from football-data.org API or manage scores via Admin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.syncFromApi(),
              icon: const Icon(Icons.cloud_download_rounded, size: 18),
              label: const Text('Sync API Matches'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.liveRed),
            const SizedBox(height: 16),
            const Text(
              'Unable to Load Scores',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => controller.syncFromApi(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry API Sync'),
            ),
          ],
        ),
      ),
    );
  }
}
