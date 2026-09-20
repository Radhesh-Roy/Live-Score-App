import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'competition_brief.dart';
import 'score_model.dart';
import 'team_brief.dart';

enum MatchStatus {
  scheduled,
  timed,
  inPlay,
  paused,
  extraTime,
  penaltyShootout,
  finished,
  suspended,
  postponed,
  cancelled;

  static MatchStatus fromString(String? statusStr) {
    switch (statusStr?.toUpperCase()) {
      case 'IN_PLAY':
      case 'INPLAY':
      case 'LIVE':
        return MatchStatus.inPlay;
      case 'PAUSED':
        return MatchStatus.paused;
      case 'EXTRA_TIME':
        return MatchStatus.extraTime;
      case 'PENALTY_SHOOTOUT':
        return MatchStatus.penaltyShootout;
      case 'FINISHED':
      case 'FT':
        return MatchStatus.finished;
      case 'TIMED':
        return MatchStatus.timed;
      case 'POSTPONED':
        return MatchStatus.postponed;
      case 'SUSPENDED':
        return MatchStatus.suspended;
      case 'CANCELLED':
        return MatchStatus.cancelled;
      default:
        return MatchStatus.scheduled;
    }
  }

  bool get isLive =>
      this == MatchStatus.inPlay ||
      this == MatchStatus.paused ||
      this == MatchStatus.extraTime ||
      this == MatchStatus.penaltyShootout;

  bool get isFinished => this == MatchStatus.finished;

  bool get isUpcoming =>
      this == MatchStatus.scheduled ||
      this == MatchStatus.timed ||
      this == MatchStatus.postponed;

  String get displayName {
    if (isLive) return 'Live';
    if (isFinished) return 'Finished';
    return 'Upcoming';
  }
}

class MatchModel {
  final String id;
  final CompetitionBrief competition;
  final DateTime utcDate;
  final MatchStatus status;
  final int? minute;
  final int? matchday;
  final String? stage;
  final String? group;
  final String? venue;
  final TeamBrief homeTeam;
  final TeamBrief awayTeam;
  final ScoreModel score;
  final String? customScoreA;
  final String? customScoreB;
  final String? oversA;
  final String? oversB;
  final String? description;

  MatchModel({
    required this.id,
    required this.competition,
    required this.utcDate,
    required this.status,
    this.minute,
    this.matchday,
    this.stage,
    this.group,
    this.venue,
    required this.homeTeam,
    required this.awayTeam,
    required this.score,
    this.customScoreA,
    this.customScoreB,
    this.oversA,
    this.oversB,
    this.description,
  });

  // Convenience getters for Home / Admin / Details UI compatibility
  String get teamA => homeTeam.displayName;
  String get teamB => awayTeam.displayName;

  String get scoreA {
    if (customScoreA != null && customScoreA!.isNotEmpty) {
      return customScoreA!;
    }
    if (score.fullTime.home != null) {
      return score.fullTime.home.toString();
    }
    return isUpcoming ? '-' : '0';
  }

  String get scoreB {
    if (customScoreB != null && customScoreB!.isNotEmpty) {
      return customScoreB!;
    }
    if (score.fullTime.away != null) {
      return score.fullTime.away.toString();
    }
    return isUpcoming ? '-' : '0';
  }

  String get matchDate => DateFormat('yyyy-MM-dd').format(utcDate.toLocal());
  String? get teamALogo => homeTeam.crest;
  String? get teamBLogo => awayTeam.crest;

  bool get isLive => status.isLive;
  bool get isFinished => status.isFinished;
  bool get isUpcoming => status.isUpcoming;

  String get normalizedStatus => status.displayName;

  factory MatchModel.createCustom({
    required String id,
    required String teamA,
    required String teamB,
    required String scoreA,
    required String scoreB,
    required String status,
    String? matchDate,
    String? venue,
    String? oversA,
    String? oversB,
    String? description,
    String? competitionName,
    String? teamALogo,
    String? teamBLogo,
  }) {
    final parsedDate = matchDate != null
        ? (DateTime.tryParse(matchDate) ?? DateTime.now())
        : DateTime.now();

    final homeInt = int.tryParse(scoreA.contains('/') ? scoreA.split('/')[0] : scoreA);
    final awayInt = int.tryParse(scoreB.contains('/') ? scoreB.split('/')[0] : scoreB);

    return MatchModel(
      id: id,
      competition: CompetitionBrief(
        id: 0,
        name: competitionName ?? 'Match',
        code: 'CUSTOM',
      ),
      utcDate: parsedDate,
      status: MatchStatus.fromString(status),
      venue: venue ?? 'Stadium',
      homeTeam: TeamBrief(id: 0, name: teamA, crest: teamALogo),
      awayTeam: TeamBrief(id: 0, name: teamB, crest: teamBLogo),
      score: ScoreModel(
        duration: 'REGULAR',
        fullTime: ScoreTime(home: homeInt, away: awayInt),
        halfTime: ScoreTime(),
      ),
      customScoreA: scoreA,
      customScoreB: scoreB,
      oversA: oversA,
      oversB: oversB,
      description: description,
    );
  }

  /// Parses from football-data.org API response
  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: (json['id'] ?? 0).toString(),
      competition: CompetitionBrief.fromJson(
        json['competition'] as Map<String, dynamic>? ?? {},
      ),
      utcDate: _parseDateTime(json['utcDate']),
      status: MatchStatus.fromString(json['status'] as String?),
      minute: json['minute'] as int?,
      matchday: json['matchday'] as int?,
      stage: json['stage'] as String?,
      group: json['group'] as String?,
      venue: json['venue'] as String? ?? 'Stadium',
      homeTeam: TeamBrief.fromJson(
        json['homeTeam'] as Map<String, dynamic>? ?? {},
      ),
      awayTeam: TeamBrief.fromJson(
        json['awayTeam'] as Map<String, dynamic>? ?? {},
      ),
      score: ScoreModel.fromJson(json['score'] as Map<String, dynamic>?),
    );
  }

  /// Parses from Cloud Firestore Document
  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MatchModel.fromMap(data, doc.id);
  }

  /// Parses from Map
  factory MatchModel.fromMap(Map<String, dynamic> map, String docId) {
    final homeTeamMap = map['homeTeam'] as Map<String, dynamic>?;
    final awayTeamMap = map['awayTeam'] as Map<String, dynamic>?;
    final competitionMap = map['competition'] as Map<String, dynamic>?;

    final homeName = map['homeTeamName'] ?? map['teamA'] ?? homeTeamMap?['name'] ?? 'Home Team';
    final awayName = map['awayTeamName'] ?? map['teamB'] ?? awayTeamMap?['name'] ?? 'Away Team';

    final teamA = TeamBrief(
      id: map['homeTeamId'] as int? ?? homeTeamMap?['id'] as int? ?? 0,
      name: homeName.toString(),
      shortName: map['homeTeamShortName']?.toString() ?? homeTeamMap?['shortName']?.toString(),
      crest: map['homeTeamCrest']?.toString() ?? map['teamALogo']?.toString() ?? homeTeamMap?['crest']?.toString(),
    );

    final teamB = TeamBrief(
      id: map['awayTeamId'] as int? ?? awayTeamMap?['id'] as int? ?? 0,
      name: awayName.toString(),
      shortName: map['awayTeamShortName']?.toString() ?? awayTeamMap?['shortName']?.toString(),
      crest: map['awayTeamCrest']?.toString() ?? map['teamBLogo']?.toString() ?? awayTeamMap?['crest']?.toString(),
    );

    final competition = competitionMap != null
        ? CompetitionBrief.fromJson(competitionMap)
        : CompetitionBrief(
            id: map['competitionId'] as int? ?? 0,
            name: map['competitionName']?.toString() ?? 'Match',
            code: map['competitionCode']?.toString() ?? 'GEN',
            emblem: map['competitionEmblem']?.toString(),
          );

    final rawScoreA = map['scoreA']?.toString();
    final rawScoreB = map['scoreB']?.toString();

    final homeInt = map['homeScore'] as int? ?? int.tryParse(rawScoreA ?? '');
    final awayInt = map['awayScore'] as int? ?? int.tryParse(rawScoreB ?? '');

    return MatchModel(
      id: docId,
      competition: competition,
      utcDate: _parseDateTime(map['utcDate'] ?? map['matchDate']),
      status: MatchStatus.fromString(map['status']?.toString()),
      minute: map['minute'] as int?,
      matchday: map['matchday'] as int?,
      stage: map['stage']?.toString(),
      group: map['group']?.toString(),
      venue: map['venue']?.toString() ?? 'Stadium',
      homeTeam: teamA,
      awayTeam: teamB,
      score: ScoreModel(
        winner: map['winner']?.toString(),
        duration: 'REGULAR',
        fullTime: ScoreTime(home: homeInt, away: awayInt),
        halfTime: ScoreTime(),
      ),
      customScoreA: rawScoreA,
      customScoreB: rawScoreB,
      oversA: map['oversA']?.toString(),
      oversB: map['oversB']?.toString(),
      description: map['description']?.toString(),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    final dateKey = DateFormat('yyyy-MM-dd').format(utcDate.toLocal());
    return {
      'id': id,
      'competitionId': competition.id,
      'competitionCode': competition.code,
      'competitionName': competition.name,
      'competitionEmblem': competition.emblem,
      'dateKey': dateKey,
      'utcDate': Timestamp.fromDate(utcDate),
      'status': status.name.toUpperCase(),
      'minute': minute,
      'matchday': matchday,
      'stage': stage,
      'group': group,
      'venue': venue,
      'homeTeamId': homeTeam.id,
      'homeTeamName': homeTeam.name,
      'homeTeamShortName': homeTeam.shortName,
      'homeTeamCrest': homeTeam.crest,
      'awayTeamId': awayTeam.id,
      'awayTeamName': awayTeam.name,
      'awayTeamShortName': awayTeam.shortName,
      'awayTeamCrest': awayTeam.crest,
      'teamA': teamA,
      'teamB': teamB,
      'scoreA': scoreA,
      'scoreB': scoreB,
      'homeScore': score.fullTime.home,
      'awayScore': score.fullTime.away,
      'winner': score.winner,
      if (oversA != null) 'oversA': oversA,
      if (oversB != null) 'oversB': oversB,
      if (description != null) 'description': description,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  MatchModel copyWith({
    String? id,
    CompetitionBrief? competition,
    DateTime? utcDate,
    MatchStatus? status,
    int? minute,
    int? matchday,
    String? stage,
    String? group,
    String? venue,
    TeamBrief? homeTeam,
    TeamBrief? awayTeam,
    ScoreModel? score,
    String? customScoreA,
    String? customScoreB,
    String? oversA,
    String? oversB,
    String? description,
  }) {
    return MatchModel(
      id: id ?? this.id,
      competition: competition ?? this.competition,
      utcDate: utcDate ?? this.utcDate,
      status: status ?? this.status,
      minute: minute ?? this.minute,
      matchday: matchday ?? this.matchday,
      stage: stage ?? this.stage,
      group: group ?? this.group,
      venue: venue ?? this.venue,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      score: score ?? this.score,
      customScoreA: customScoreA ?? this.customScoreA,
      customScoreB: customScoreB ?? this.customScoreB,
      oversA: oversA ?? this.oversA,
      oversB: oversB ?? this.oversB,
      description: description ?? this.description,
    );
  }
}
