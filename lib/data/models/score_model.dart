class ScoreTime {
  final int? home;
  final int? away;

  ScoreTime({this.home, this.away});

  factory ScoreTime.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ScoreTime();
    return ScoreTime(
      home: json['home'] as int?,
      away: json['away'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {'home': home, 'away': away};
}

class ScoreModel {
  final String? winner;
  final String? duration;
  final ScoreTime fullTime;
  final ScoreTime halfTime;

  ScoreModel({
    this.winner,
    this.duration,
    required this.fullTime,
    required this.halfTime,
  });

  factory ScoreModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ScoreModel(
        fullTime: ScoreTime(),
        halfTime: ScoreTime(),
      );
    }
    return ScoreModel(
      winner: json['winner'] as String?,
      duration: json['duration'] as String?,
      fullTime: ScoreTime.fromJson(json['fullTime'] as Map<String, dynamic>?),
      halfTime: ScoreTime.fromJson(json['halfTime'] as Map<String, dynamic>?),
    );
  }

  factory ScoreModel.fromFirestore(Map<String, dynamic> json) {
    final home = json['homeScore'] as int?;
    final away = json['awayScore'] as int?;
    return ScoreModel(
      winner: json['winner'] as String?,
      duration: 'REGULAR',
      fullTime: ScoreTime(home: home, away: away),
      halfTime: ScoreTime(),
    );
  }

  Map<String, dynamic> toJson() => {
        'winner': winner,
        'duration': duration,
        'fullTime': fullTime.toJson(),
        'halfTime': halfTime.toJson(),
      };

  String displayScore({bool isLive = false}) {
    if (fullTime.home != null && fullTime.away != null) {
      return '${fullTime.home} - ${fullTime.away}';
    }
    return '- : -';
  }
}
