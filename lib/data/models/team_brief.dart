class TeamBrief {
  final int id;
  final String name;
  final String? shortName;
  final String? tla;
  final String? crest;

  TeamBrief({
    required this.id,
    required this.name,
    this.shortName,
    this.tla,
    this.crest,
  });

  factory TeamBrief.fromJson(Map<String, dynamic> json) {
    return TeamBrief(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown Team',
      shortName: json['shortName'] as String?,
      tla: json['tla'] as String?,
      crest: json['crest'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shortName': shortName,
        'tla': tla,
        'crest': crest,
      };

  String get displayName => shortName ?? tla ?? name;
}
