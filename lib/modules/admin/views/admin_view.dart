import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Score Admin'),
        actions: [
          IconButton(
            tooltip: 'Sync Matches from Football API',
            icon: const Icon(Icons.sync_rounded),
            onPressed: () => controller.syncApiMatches(),
          ),
          IconButton(
            tooltip: 'Add New Match',
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _showAddMatchSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingMatches.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accentBlue),
          );
        }

        if (controller.matches.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_cricket, size: 56, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  const Text(
                    'No Matches in Database',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first match or sync live matches from football-data.org.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _showAddMatchSheet(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create New Match'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => controller.syncApiMatches(),
                    icon: const Icon(Icons.sync_rounded),
                    label: const Text('Sync Matches from Football API'),
                  ),
                ],
              ),
            ),
          );
        }

        final currentMatch = controller.selectedMatch.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Match Selector Card
              _buildMatchSelectorCard(context),
              const SizedBox(height: 16),

              if (currentMatch != null) ...[
                // Team A Score Control
                _buildScoreControlCard(
                  teamName: currentMatch.teamA,
                  label: 'Team A Score',
                  scoreController: controller.scoreATextController,
                  onIncrement: controller.incrementScoreA,
                  onDecrement: controller.decrementScoreA,
                  oversController: controller.oversAController,
                  accentColor: AppTheme.accentBlue,
                ),
                const SizedBox(height: 16),

                // Team B Score Control
                _buildScoreControlCard(
                  teamName: currentMatch.teamB,
                  label: 'Team B Score',
                  scoreController: controller.scoreBTextController,
                  onIncrement: controller.incrementScoreB,
                  onDecrement: controller.decrementScoreB,
                  oversController: controller.oversBController,
                  accentColor: AppTheme.upcomingOrange,
                ),
                const SizedBox(height: 16),

                // Match Status Selector Card
                _buildStatusSelectorCard(),
                const SizedBox(height: 16),

                // Venue & Summary Card
                _buildVenueAndDetailsCard(),
                const SizedBox(height: 24),

                // Update Score Button
                Obx(() {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: controller.isUpdating.value
                        ? null
                        : () => controller.updateScore(),
                    child: controller.isUpdating.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Update Score',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  );
                }),
                const SizedBox(height: 16),

                // Delete Match Option
                TextButton.icon(
                  onPressed: () => _confirmDeleteMatch(context),
                  icon: const Icon(Icons.delete_outline, color: AppTheme.liveRed, size: 18),
                  label: const Text(
                    'Delete Match from Firestore',
                    style: TextStyle(color: AppTheme.liveRed, fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMatchSelectorCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Match',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => _showAddMatchSheet(context),
                child: const Row(
                  children: [
                    Icon(Icons.add, size: 16, color: AppTheme.accentBlue),
                    SizedBox(width: 4),
                    Text(
                      'New Match',
                      style: TextStyle(
                        color: AppTheme.accentBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              dropdownColor: AppTheme.cardBackgroundLight,
              value: controller.selectedMatch.value?.id,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textPrimary),
              items: controller.matches.map((match) {
                return DropdownMenuItem<String>(
                  value: match.id,
                  child: Text(
                    '${match.teamA} vs ${match.teamB} (${match.normalizedStatus})',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (id) {
                if (id != null) {
                  final found = controller.matches.firstWhereOrNull((m) => m.id == id);
                  if (found != null) controller.selectMatch(found);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreControlCard({
    required String teamName,
    required String label,
    required TextEditingController scoreController,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required TextEditingController oversController,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                teamName,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Score Display & Buttons Row
          Row(
            children: [
              // Decrement Button [ - ]
              Material(
                color: AppTheme.cardBackgroundLight,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onDecrement,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.cardBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.remove, color: AppTheme.textPrimary, size: 26),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Editable Score Field
              Expanded(
                child: TextField(
                  controller: scoreController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    fillColor: AppTheme.cardBackgroundLight,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.cardBorder),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(width: 12),

              // Increment Button [ + ]
              Material(
                color: AppTheme.accentBlue,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onIncrement,
                  child: const SizedBox(
                    width: 54,
                    height: 54,
                    child: Center(
                      child: Icon(Icons.add, color: Colors.white, size: 26),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Overs TextField
          Row(
            children: [
              const Text(
                'Overs (optional):',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: oversController,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 18.4',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelectorCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Match Status',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: AppTheme.cardBackgroundLight,
                  value: controller.selectedStatus.value,
                  icon: const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.textPrimary),
                  items: controller.statusOptions.map((status) {
                    Color statusColor = AppTheme.upcomingOrange;
                    if (status == 'Live') statusColor = AppTheme.liveRed;
                    if (status == 'Finished') statusColor = AppTheme.accentGreen;

                    return DropdownMenuItem<String>(
                      value: status,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            status,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) controller.selectedStatus.value = val;
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVenueAndDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Venue & Match Summary',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.venueController,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              labelText: 'Venue',
              prefixIcon: Icon(Icons.stadium_outlined, size: 20, color: AppTheme.textMuted),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.descriptionController,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              labelText: 'Match Note / Summary',
              prefixIcon: Icon(Icons.info_outline_rounded, size: 20, color: AppTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMatch(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Delete Match?'),
        content: Text(
          'Are you sure you want to remove "${controller.selectedMatch.value?.teamA} vs ${controller.selectedMatch.value?.teamB}" from Firestore?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.liveRed),
            onPressed: () {
              Get.back();
              controller.deleteSelectedMatch();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddMatchSheet(BuildContext context) {
    final teamAInput = TextEditingController();
    final teamBInput = TextEditingController();
    final venueInput = TextEditingController(text: 'Mirpur Stadium');
    final scoreAInput = TextEditingController(text: '0');
    final scoreBInput = TextEditingController(text: '0');
    final statusVal = 'Live'.obs;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create New Match',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textMuted),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: teamAInput,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Team A (e.g. Bangladesh)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: teamBInput,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Team B (e.g. India)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: scoreAInput,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(labelText: 'Score A (e.g. 125/4)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: scoreBInput,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(labelText: 'Score B (e.g. 124/8)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: venueInput,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Venue (e.g. Mirpur Stadium)'),
              ),
              const SizedBox(height: 12),
              Obx(() {
                return DropdownButtonFormField<String>(
                  initialValue: statusVal.value,
                  dropdownColor: AppTheme.cardBackgroundLight,
                  decoration: const InputDecoration(labelText: 'Initial Status'),
                  items: const [
                    DropdownMenuItem(value: 'Live', child: Text('Live')),
                    DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
                    DropdownMenuItem(value: 'Finished', child: Text('Finished')),
                  ],
                  onChanged: (val) {
                    if (val != null) statusVal.value = val;
                  },
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (teamAInput.text.trim().isEmpty || teamBInput.text.trim().isEmpty) {
                    Get.snackbar('Required', 'Please provide both team names.');
                    return;
                  }
                  controller.createNewMatch(
                    teamA: teamAInput.text.trim(),
                    teamB: teamBInput.text.trim(),
                    venue: venueInput.text.trim(),
                    status: statusVal.value,
                    scoreA: scoreAInput.text.trim(),
                    scoreB: scoreBInput.text.trim(),
                  );
                },
                child: const Text('Add Match to Firestore'),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
