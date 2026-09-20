import 'package:flutter_test/flutter_test.dart';
import 'package:live_score_app/data/models/match_model.dart';
import 'package:live_score_app/data/models/score_model.dart';

void main() {
  group('MatchModel Tests', () {
    test('MatchModel.createCustom creates custom matches and supports serialization', () {
      final match = MatchModel.createCustom(
        id: 'custom_101',
        teamA: 'Bangladesh',
        teamB: 'India',
        scoreA: '125/4',
        scoreB: '124/8',
        status: 'Live',
        matchDate: '2026-09-20',
        venue: 'Mirpur Stadium',
        oversA: '19.2',
        oversB: '20.0',
        description: 'Thriller in Mirpur',
      );

      expect(match.id, 'custom_101');
      expect(match.teamA, 'Bangladesh');
      expect(match.teamB, 'India');
      expect(match.scoreA, '125/4');
      expect(match.scoreB, '124/8');
      expect(match.oversA, '19.2');
      expect(match.oversB, '20.0');
      expect(match.venue, 'Mirpur Stadium');
      expect(match.description, 'Thriller in Mirpur');
      expect(match.isLive, isTrue);
      expect(match.isUpcoming, isFalse);
      expect(match.isFinished, isFalse);
      expect(match.normalizedStatus, 'Live');

      // Test map serialization & deserialization
      final map = match.toMap();
      expect(map['teamA'], 'Bangladesh');
      expect(map['teamB'], 'India');
      expect(map['scoreA'], '125/4');
      expect(map['scoreB'], '124/8');
      expect(map['oversA'], '19.2');
      expect(map['oversB'], '20.0');
      expect(map['venue'], 'Mirpur Stadium');

      final fromMapMatch = MatchModel.fromMap(map, 'custom_101');
      expect(fromMapMatch.id, 'custom_101');
      expect(fromMapMatch.teamA, 'Bangladesh');
      expect(fromMapMatch.teamB, 'India');
      expect(fromMapMatch.scoreA, '125/4');
      expect(fromMapMatch.scoreB, '124/8');
      expect(fromMapMatch.isLive, isTrue);
    });

    test('MatchModel.fromJson parses football-data.org API payload correctly', () {
      final apiJson = {
        'id': 438123,
        'utcDate': '2026-09-20T19:00:00Z',
        'status': 'IN_PLAY',
        'minute': 68,
        'matchday': 5,
        'stage': 'REGULAR_SEASON',
        'venue': 'Anfield',
        'competition': {
          'id': 2021,
          'name': 'Premier League',
          'code': 'PL',
          'type': 'LEAGUE',
          'emblem': 'https://crests.football-data.org/PL.png',
        },
        'homeTeam': {
          'id': 64,
          'name': 'Liverpool FC',
          'shortName': 'Liverpool',
          'tla': 'LIV',
          'crest': 'https://crests.football-data.org/64.png',
        },
        'awayTeam': {
          'id': 65,
          'name': 'Manchester City FC',
          'shortName': 'Man City',
          'tla': 'MCI',
          'crest': 'https://crests.football-data.org/65.png',
        },
        'score': {
          'winner': 'HOME_TEAM',
          'duration': 'REGULAR',
          'fullTime': {'home': 2, 'away': 1},
          'halfTime': {'home': 1, 'away': 0},
        },
      };

      final match = MatchModel.fromJson(apiJson);

      expect(match.id, '438123');
      expect(match.teamA, 'Liverpool');
      expect(match.teamB, 'Man City');
      expect(match.scoreA, '2');
      expect(match.scoreB, '1');
      expect(match.minute, 68);
      expect(match.venue, 'Anfield');
      expect(match.competition.name, 'Premier League');
      expect(match.competition.code, 'PL');
      expect(match.teamALogo, 'https://crests.football-data.org/64.png');
      expect(match.teamBLogo, 'https://crests.football-data.org/65.png');
      expect(match.isLive, isTrue);
      expect(match.normalizedStatus, 'Live');
    });

    test('MatchStatus variations and transitions work correctly', () {
      final scheduled = MatchStatus.fromString('TIMED');
      expect(scheduled.isUpcoming, isTrue);
      expect(scheduled.isLive, isFalse);
      expect(scheduled.displayName, 'Upcoming');

      final live = MatchStatus.fromString('IN_PLAY');
      expect(live.isLive, isTrue);
      expect(live.displayName, 'Live');

      final finished = MatchStatus.fromString('FINISHED');
      expect(finished.isFinished, isTrue);
      expect(finished.displayName, 'Finished');
    });

    test('ScoreModel and ScoreTime format scores accurately', () {
      final score = ScoreModel(
        duration: 'REGULAR',
        fullTime: ScoreTime(home: 3, away: 2),
        halfTime: ScoreTime(home: 1, away: 0),
      );
      expect(score.displayScore(), '3 - 2');
      expect(score.fullTime.home, 3);
      expect(score.fullTime.away, 2);

      final emptyScore = ScoreModel(
        fullTime: ScoreTime(),
        halfTime: ScoreTime(),
      );
      expect(emptyScore.displayScore(), '- : -');
    });
  });
}
