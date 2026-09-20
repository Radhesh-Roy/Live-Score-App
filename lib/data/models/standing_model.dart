import 'team_brief.dart';

class StandingEntry {
  final int position;
  final TeamBrief team;
  final int playedGames;
  final String? form;
  final int won;
  final int draw;
  final int lost;
  final int points;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;

  StandingEntry({
    required this.position,
    required this.team,
    required this.playedGames,
    this.form,
    required this.won,
    required this.draw,
    required this.lost,
    required this.points,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
  });

  factory StandingEntry.fromJson(Map<String, dynamic> json) {
    return StandingEntry(
      position: json['position'] as int? ?? 0,
      team: TeamBrief.fromJson(json['team'] as Map<String, dynamic>? ?? {}),
      playedGames: json['playedGames'] as int? ?? 0,
      form: json['form'] as String?,
      won: json['won'] as int? ?? 0,
      draw: json['draw'] as int? ?? 0,
      lost: json['lost'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      goalsFor: json['goalsFor'] as int? ?? 0,
      goalsAgainst: json['goalsAgainst'] as int? ?? 0,
      goalDifference: json['goalDifference'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'position': position,
        'team': team.toJson(),
        'playedGames': playedGames,
        'form': form,
        'won': won,
        'draw': draw,
        'lost': lost,
        'points': points,
        'goalsFor': goalsFor,
        'goalsAgainst': goalsAgainst,
        'goalDifference': goalDifference,
      };
}

class StandingTable {
  final String stage;
  final String type; // TOTAL, HOME, AWAY
  final String? group;
  final List<StandingEntry> table;

  StandingTable({
    required this.stage,
    required this.type,
    this.group,
    required this.table,
  });

  factory StandingTable.fromJson(Map<String, dynamic> json) {
    return StandingTable(
      stage: json['stage'] as String? ?? 'REGULAR_SEASON',
      type: json['type'] as String? ?? 'TOTAL',
      group: json['group'] as String?,
      table: (json['table'] as List<dynamic>?)
              ?.map((e) => StandingEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'stage': stage,
        'type': type,
        'group': group,
        'table': table.map((e) => e.toJson()).toList(),
      };
}
