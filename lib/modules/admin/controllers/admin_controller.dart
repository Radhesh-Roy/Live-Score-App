import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/match_model.dart';
import '../../../data/repositories/match_repository.dart';

class AdminController extends GetxController {
  final MatchRepository _matchRepository;

  AdminController({MatchRepository? matchRepository})
      : _matchRepository = matchRepository ?? Get.find<MatchRepository>();

  final RxList<MatchModel> matches = <MatchModel>[].obs;
  final Rx<MatchModel?> selectedMatch = Rx<MatchModel?>(null);

  final RxInt scoreAInt = 0.obs;
  final RxInt scoreBInt = 0.obs;

  late TextEditingController scoreATextController;
  late TextEditingController scoreBTextController;
  late TextEditingController venueController;
  late TextEditingController descriptionController;
  late TextEditingController oversAController;
  late TextEditingController oversBController;

  final RxString selectedStatus = 'Live'.obs;
  final RxBool isUpdating = false.obs;
  final RxBool isLoadingMatches = true.obs;

  final List<String> statusOptions = const ['Live', 'Upcoming', 'Finished'];

  StreamSubscription<List<MatchModel>>? _matchesSub;

  @override
  void onInit() {
    super.onInit();
    scoreATextController = TextEditingController();
    scoreBTextController = TextEditingController();
    venueController = TextEditingController();
    descriptionController = TextEditingController();
    oversAController = TextEditingController();
    oversBController = TextEditingController();

    _loadMatches();
  }

  void _loadMatches() {
    isLoadingMatches.value = true;
    _matchesSub?.cancel();
    _matchesSub = _matchRepository.getMatchesStream().listen((list) {
      matches.value = list;
      isLoadingMatches.value = false;

      // Check if an argument was passed
      final passedMatch = Get.arguments;
      if (selectedMatch.value == null && passedMatch is MatchModel) {
        final matchInList = list.firstWhereOrNull((m) => m.id == passedMatch.id) ?? passedMatch;
        selectMatch(matchInList);
      } else if (selectedMatch.value == null && list.isNotEmpty) {
        selectMatch(list.first);
      } else if (selectedMatch.value != null) {
        // Refresh selected match data from stream
        final current = list.firstWhereOrNull((m) => m.id == selectedMatch.value!.id);
        if (current != null) {
          selectedMatch.value = current;
        }
      }
    });
  }

  void selectMatch(MatchModel match) {
    selectedMatch.value = match;
    selectedStatus.value = match.normalizedStatus;
    venueController.text = match.venue ?? '';
    descriptionController.text = match.description ?? '';
    oversAController.text = match.oversA ?? '';
    oversBController.text = match.oversB ?? '';

    scoreATextController.text = match.scoreA;
    scoreBTextController.text = match.scoreB;

    // Parse numeric component for +/- buttons
    scoreAInt.value = _parseScoreNumber(match.scoreA);
    scoreBInt.value = _parseScoreNumber(match.scoreB);
  }

  int _parseScoreNumber(String scoreStr) {
    if (scoreStr.contains('/')) {
      final parts = scoreStr.split('/');
      return int.tryParse(parts[0].trim()) ?? 0;
    }
    return int.tryParse(scoreStr.trim()) ?? 0;
  }

  String _formatScoreWithWickets(String currentText, int newScore) {
    if (currentText.contains('/')) {
      final parts = currentText.split('/');
      final wickets = parts.length > 1 ? parts[1] : '0';
      return '$newScore/$wickets';
    }
    return '$newScore';
  }

  void incrementScoreA() {
    scoreAInt.value++;
    scoreATextController.text = _formatScoreWithWickets(
      scoreATextController.text,
      scoreAInt.value,
    );
  }

  void decrementScoreA() {
    if (scoreAInt.value > 0) {
      scoreAInt.value--;
      scoreATextController.text = _formatScoreWithWickets(
        scoreATextController.text,
        scoreAInt.value,
      );
    }
  }

  void incrementScoreB() {
    scoreBInt.value++;
    scoreBTextController.text = _formatScoreWithWickets(
      scoreBTextController.text,
      scoreBInt.value,
    );
  }

  void decrementScoreB() {
    if (scoreBInt.value > 0) {
      scoreBInt.value--;
      scoreBTextController.text = _formatScoreWithWickets(
        scoreBTextController.text,
        scoreBInt.value,
      );
    }
  }

  Future<void> updateScore() async {
    final current = selectedMatch.value;
    if (current == null) {
      Get.snackbar(
        'Warning',
        'Please select a match first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isUpdating.value = true;

      await _matchRepository.updateMatchScore(
        matchId: current.id,
        scoreA: scoreATextController.text.trim().isEmpty ? '0' : scoreATextController.text.trim(),
        scoreB: scoreBTextController.text.trim().isEmpty ? '0' : scoreBTextController.text.trim(),
        status: selectedStatus.value,
        venue: venueController.text.trim().isNotEmpty ? venueController.text.trim() : null,
        description: descriptionController.text.trim().isNotEmpty ? descriptionController.text.trim() : null,
        oversA: oversAController.text.trim().isNotEmpty ? oversAController.text.trim() : null,
        oversB: oversBController.text.trim().isNotEmpty ? oversBController.text.trim() : null,
      );

      Get.snackbar(
        'Success',
        'Match scores and status updated in Firestore!',
        backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update match: $e',
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> createNewMatch({
    required String teamA,
    required String teamB,
    required String venue,
    required String status,
    required String scoreA,
    required String scoreB,
    String? matchDate,
    String? oversA,
    String? oversB,
    String? description,
  }) async {
    try {
      isUpdating.value = true;
      final newMatch = MatchModel.createCustom(
        id: '',
        teamA: teamA,
        teamB: teamB,
        scoreA: scoreA.isEmpty ? '0' : scoreA,
        scoreB: scoreB.isEmpty ? '0' : scoreB,
        status: status,
        matchDate: matchDate ?? DateTime.now().toString().substring(0, 10),
        venue: venue,
        oversA: oversA,
        oversB: oversB,
        description: description,
      );

      final newId = await _matchRepository.createMatch(newMatch);
      final createdMatch = newMatch.copyWith(id: newId);
      selectMatch(createdMatch);

      Get.back(); // close modal dialog
      Get.snackbar(
        'Match Created',
        '$teamA vs $teamB created in Firestore!',
        backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create match: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> syncApiMatches() async {
    try {
      isUpdating.value = true;
      final synced = await _matchRepository.syncMatchesFromApi();
      Get.snackbar(
        'API Sync Complete',
        'Synced ${synced.length} live matches from football-data.org.',
        backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Sync Error',
        '$e',
        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> deleteSelectedMatch() async {
    final current = selectedMatch.value;
    if (current == null) return;

    try {
      isUpdating.value = true;
      await _matchRepository.deleteMatch(current.id);
      selectedMatch.value = matches.isNotEmpty ? matches.first : null;
      Get.snackbar(
        'Deleted',
        'Match was removed from Firestore.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  @override
  void onClose() {
    _matchesSub?.cancel();
    scoreATextController.dispose();
    scoreBTextController.dispose();
    venueController.dispose();
    descriptionController.dispose();
    oversAController.dispose();
    oversBController.dispose();
    super.onClose();
  }
}
