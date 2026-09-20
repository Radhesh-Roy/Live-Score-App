import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/match_model.dart';
import '../../../data/repositories/match_repository.dart';

class HomeController extends GetxController {
  final MatchRepository _matchRepository;

  HomeController({MatchRepository? matchRepository})
      : _matchRepository = matchRepository ?? Get.find<MatchRepository>();

  final RxList<MatchModel> allMatches = <MatchModel>[].obs;
  final RxString selectedFilter = 'All'.obs;
  final RxBool isLoading = true.obs;
  final RxBool isSyncing = false.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<List<MatchModel>>? _matchesSubscription;

  final List<String> filterOptions = const ['All', 'Live', 'Upcoming', 'Finished'];

  @override
  void onInit() {
    super.onInit();
    _listenToMatches();
    // Auto-sync live API data from football-data.org
    syncFromApi(silent: true);
  }

  void _listenToMatches() {
    isLoading.value = true;
    errorMessage.value = '';

    _matchesSubscription?.cancel();
    _matchesSubscription = _matchRepository.getMatchesStream().listen(
      (matches) {
        allMatches.value = matches;
        isLoading.value = false;

        // Auto-seed sample matches if Firestore has 0 documents and API sync didn't run
        if (matches.isEmpty && !isSyncing.value) {
          _matchRepository.seedInitialMatches();
        }
      },
      onError: (error) {
        errorMessage.value = error.toString();
        isLoading.value = false;
      },
    );
  }

  Future<void> syncFromApi({bool silent = false}) async {
    try {
      isSyncing.value = true;
      final synced = await _matchRepository.syncMatchesFromApi();

      if (!silent) {
        Get.snackbar(
          'API Sync Successful',
          'Fetched and synced ${synced.length} matches from football-data.org API.',
          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (!silent) {
        Get.snackbar(
          'API Sync Notice',
          '$e',
          backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } finally {
      isSyncing.value = false;
    }
  }

  List<MatchModel> get filteredMatches {
    final filter = selectedFilter.value;
    if (filter == 'Live') {
      return allMatches.where((m) => m.isLive).toList();
    } else if (filter == 'Upcoming') {
      return allMatches.where((m) => m.isUpcoming).toList();
    } else if (filter == 'Finished') {
      return allMatches.where((m) => m.isFinished).toList();
    }
    return allMatches;
  }

  int get liveCount => allMatches.where((m) => m.isLive).length;
  int get upcomingCount => allMatches.where((m) => m.isUpcoming).length;
  int get finishedCount => allMatches.where((m) => m.isFinished).length;

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<void> seedSampleData() async {
    try {
      isLoading.value = true;
      await syncFromApi();
    } catch (e) {
      await _matchRepository.seedInitialMatches();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _matchesSubscription?.cancel();
    super.onClose();
  }
}
