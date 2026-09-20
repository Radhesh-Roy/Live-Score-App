import '../models/competition_brief.dart';
import '../models/match_model.dart';
import '../models/standing_model.dart';
import 'dio_client.dart';

class FootballApiService {
  final DioClient _dioClient;

  FootballApiService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  /// Fetches matches across competitions. If [dateStr] (YYYY-MM-DD) is provided, filters by date.
  Future<List<MatchModel>> fetchMatches({String? dateStr}) async {
    final Map<String, dynamic> queryParams = {};
    if (dateStr != null && dateStr.isNotEmpty) {
      queryParams['date'] = dateStr;
    }

    final data = await _dioClient.get(
      '/matches',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (data is Map<String, dynamic>) {
      final matchesJson = data['matches'] as List<dynamic>? ?? [];
      return matchesJson
          .map((m) => MatchModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetches details for a specific match ID.
  Future<MatchModel?> fetchMatchDetails(int matchId) async {
    final data = await _dioClient.get('/matches/$matchId');
    if (data is Map<String, dynamic>) {
      return MatchModel.fromJson(data);
    }
    return null;
  }

  /// Fetches all available competitions.
  Future<List<CompetitionBrief>> fetchCompetitions() async {
    final data = await _dioClient.get('/competitions');
    if (data is Map<String, dynamic>) {
      final compsJson = data['competitions'] as List<dynamic>? ?? [];
      return compsJson
          .map((c) => CompetitionBrief.fromJson(c as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetches matches for a specific competition code (e.g. 'PL', 'BL1', 'PD').
  Future<List<MatchModel>> fetchCompetitionMatches(String code) async {
    final data = await _dioClient.get('/competitions/$code/matches');
    if (data is Map<String, dynamic>) {
      final matchesJson = data['matches'] as List<dynamic>? ?? [];
      return matchesJson
          .map((m) => MatchModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetches standings for a specific competition.
  Future<List<StandingTable>> fetchStandings(String competitionCode) async {
    try {
      final data = await _dioClient.get('/competitions/$competitionCode/standings');
      if (data is Map<String, dynamic>) {
        final standingsJson = data['standings'] as List<dynamic>? ?? [];
        return standingsJson
            .map((s) => StandingTable.fromJson(s as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      return [];
    }
    return [];
  }
}
