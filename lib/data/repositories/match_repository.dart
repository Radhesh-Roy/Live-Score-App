import '../api/football_api_service.dart';
import '../models/match_model.dart';
import '../models/standing_model.dart';
import '../services/firestore_service.dart';

class MatchRepository {
  final FirestoreService _firestoreService;
  final FootballApiService _footballApiService;

  MatchRepository({
    FirestoreService? firestoreService,
    FootballApiService? footballApiService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _footballApiService = footballApiService ?? FootballApiService();

  /// Real-time stream from Firestore `matches` collection
  Stream<List<MatchModel>> getMatchesStream() {
    return _firestoreService.getMatchesStream();
  }

  /// Real-time stream for a single match document
  Stream<MatchModel?> getMatchStream(String matchId) {
    return _firestoreService.getMatchStream(matchId);
  }

  /// One-time fetch of single match from Firestore
  Future<MatchModel?> getMatchById(String matchId) {
    return _firestoreService.getMatchById(matchId);
  }

  /// Fetches matches directly from football-data.org API and synchronizes them into Firestore
  Future<List<MatchModel>> syncMatchesFromApi({String? dateStr}) async {
    final apiMatches = await _footballApiService.fetchMatches(dateStr: dateStr);
    if (apiMatches.isNotEmpty) {
      await _firestoreService.batchUpsertMatches(apiMatches);
    }
    return apiMatches;
  }

  /// Directly fetches matches from football-data.org without forcing Firestore write
  Future<List<MatchModel>> fetchMatchesDirectly({String? dateStr}) {
    return _footballApiService.fetchMatches(dateStr: dateStr);
  }

  /// Fetches single match details directly from API
  Future<MatchModel?> fetchMatchDetailsFromApi(int matchId) {
    return _footballApiService.fetchMatchDetails(matchId);
  }

  /// Fetches competition standings from API
  Future<List<StandingTable>> fetchStandings(String competitionCode) {
    return _footballApiService.fetchStandings(competitionCode);
  }

  /// Updates match score and status in Firestore
  Future<void> updateMatchScore({
    required String matchId,
    required String scoreA,
    required String scoreB,
    required String status,
    String? oversA,
    String? oversB,
    String? description,
    String? venue,
    String? matchDate,
  }) {
    return _firestoreService.updateMatchScore(
      matchId: matchId,
      scoreA: scoreA,
      scoreB: scoreB,
      status: status,
      oversA: oversA,
      oversB: oversB,
      description: description,
      venue: venue,
      matchDate: matchDate,
    );
  }

  /// Creates a new match in Firestore
  Future<String> createMatch(MatchModel match) {
    return _firestoreService.createMatch(match);
  }

  /// Deletes a match from Firestore
  Future<void> deleteMatch(String matchId) {
    return _firestoreService.deleteMatch(matchId);
  }

  /// Seeds initial matches if needed
  Future<void> seedInitialMatches() {
    return _firestoreService.seedInitialMatches();
  }
}
