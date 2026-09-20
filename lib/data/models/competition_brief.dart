class CompetitionBrief {
  final int id;
  final String name;
  final String code;
  final String? type;
  final String? emblem;

  CompetitionBrief({
    required this.id,
    required this.name,
    required this.code,
    this.type,
    this.emblem,
  });

  factory CompetitionBrief.fromJson(Map<String, dynamic> json) {
    return CompetitionBrief(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'League',
      code: json['code'] as String? ?? 'UNK',
      type: json['type'] as String?,
      emblem: json['emblem'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'type': type,
        'emblem': emblem,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompetitionBrief &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
