import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/competition_brief.dart';
import '../models/match_model.dart';
import '../models/score_model.dart';
import '../models/team_brief.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _matchesCollection =>
      _firestore.collection('matches');

  /// Real-time stream of all matches ordered by date
  Stream<List<MatchModel>> getMatchesStream() {
    return _matchesCollection.snapshots().map((snapshot) {
      final matches = snapshot.docs.map((doc) => MatchModel.fromFirestore(doc)).toList();
      // Sort client-side by utcDate
      matches.sort((a, b) => a.utcDate.compareTo(b.utcDate));
      return matches;
    });
  }

  /// Real-time stream for a single match document
  Stream<MatchModel?> getMatchStream(String matchId) {
    return _matchesCollection.doc(matchId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return MatchModel.fromFirestore(doc);
    });
  }

  /// Fetch single match directly
  Future<MatchModel?> getMatchById(String matchId) async {
    final doc = await _matchesCollection.doc(matchId).get();
    if (!doc.exists) return null;
    return MatchModel.fromFirestore(doc);
  }

  /// Batch upserts matches from API into Firestore
  Future<int> batchUpsertMatches(List<MatchModel> matches) async {
    if (matches.isEmpty) return 0;

    final batch = _firestore.batch();
    int count = 0;

    for (final match in matches) {
      final docRef = _matchesCollection.doc(match.id);
      batch.set(docRef, match.toMap(), SetOptions(merge: true));
      count++;
    }

    await batch.commit();
    return count;
  }

  /// Update match score and status
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
  }) async {
    final homeInt = int.tryParse(scoreA.contains('/') ? scoreA.split('/')[0] : scoreA);
    final awayInt = int.tryParse(scoreB.contains('/') ? scoreB.split('/')[0] : scoreB);

    final Map<String, dynamic> updates = {
      'scoreA': scoreA,
      'scoreB': scoreB,
      'homeScore': homeInt,
      'awayScore': awayInt,
      'status': status.toUpperCase(),
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    if (oversA != null) updates['oversA'] = oversA;
    if (oversB != null) updates['oversB'] = oversB;
    if (description != null) updates['description'] = description;
    if (venue != null) updates['venue'] = venue;
    if (matchDate != null) updates['matchDate'] = matchDate;

    await _matchesCollection.doc(matchId).set(updates, SetOptions(merge: true));
  }

  /// Add a new match document
  Future<String> createMatch(MatchModel match) async {
    final data = match.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    final docRef = await _matchesCollection.add(data);
    return docRef.id;
  }

  /// Delete a match document
  Future<void> deleteMatch(String matchId) async {
    await _matchesCollection.doc(matchId).delete();
  }

  /// Seeds sample matches if the collection is empty
  Future<void> seedInitialMatches() async {
    final currentDocs = await _matchesCollection.limit(1).get();
    if (currentDocs.docs.isNotEmpty) return;

    final initialMatches = [
      MatchModel(
        id: 'sample_1',
        competition: CompetitionBrief(
          id: 2021,
          name: 'Premier League',
          code: 'PL',
          emblem: 'https://crests.football-data.org/PL.png',
        ),
        utcDate: DateTime.now(),
        status: MatchStatus.inPlay,
        minute: 68,
        venue: 'Emirates Stadium, London',
        homeTeam: TeamBrief(
          id: 57,
          name: 'Arsenal FC',
          shortName: 'Arsenal',
          crest: 'https://crests.football-data.org/57.png',
        ),
        awayTeam: TeamBrief(
          id: 65,
          name: 'Manchester City FC',
          shortName: 'Man City',
          crest: 'https://crests.football-data.org/65.png',
        ),
        score: ScoreModel(
          winner: null,
          duration: 'REGULAR',
          fullTime: ScoreTime(home: 2, away: 1),
          halfTime: ScoreTime(home: 1, away: 0),
        ),
        customScoreA: '2',
        customScoreB: '1',
      ),
      MatchModel(
        id: 'sample_2',
        competition: CompetitionBrief(
          id: 2014,
          name: 'La Liga',
          code: 'PD',
          emblem: 'https://crests.football-data.org/laliga.png',
        ),
        utcDate: DateTime.now().add(const Duration(hours: 2)),
        status: MatchStatus.timed,
        venue: 'Santiago Bernabéu, Madrid',
        homeTeam: TeamBrief(
          id: 86,
          name: 'Real Madrid CF',
          shortName: 'Real Madrid',
          crest: 'https://crests.football-data.org/86.png',
        ),
        awayTeam: TeamBrief(
          id: 81,
          name: 'FC Barcelona',
          shortName: 'Barcelona',
          crest: 'https://crests.football-data.org/81.png',
        ),
        score: ScoreModel(
          fullTime: ScoreTime(),
          halfTime: ScoreTime(),
        ),
      ),
    ];

    for (final match in initialMatches) {
      await _matchesCollection.doc(match.id).set(match.toMap(), SetOptions(merge: true));
    }
  }
}
