class ApiConstants {
  static const String baseUrl = 'https://api.football-data.org/v4';
  static const String defaultApiToken = '3c1a3a1b631a4036a81aa5028d3b30e5';

  static const List<String> freeCompetitionCodes = [
    'PL',
    'ELC',
    'BL1',
    'PD',
    'SA',
    'FL1',
    'DED',
    'PPL',
    'BSA',
    'CL',
    'EC',
    'WC',
  ];

  static const Map<String, Map<String, String>> freeCompetitions = {
    'PL': {'name': 'Premier League', 'country': 'England', 'flag': '🏴󠁧󠁢󠁥󠁮󠁧󠁿'},
    'ELC': {'name': 'Championship', 'country': 'England', 'flag': '🏴󠁧󠁢󠁥󠁮󠁧󠁿'},
    'BL1': {'name': 'Bundesliga', 'country': 'Germany', 'flag': '🇩🇪'},
    'PD': {'name': 'La Liga', 'country': 'Spain', 'flag': '🇪🇸'},
    'SA': {'name': 'Serie A', 'country': 'Italy', 'flag': '🇮🇹'},
    'FL1': {'name': 'Ligue 1', 'country': 'France', 'flag': '🇫🇷'},
    'DED': {'name': 'Eredivisie', 'country': 'Netherlands', 'flag': '🇳🇱'},
    'PPL': {'name': 'Primeira Liga', 'country': 'Portugal', 'flag': '🇵🇹'},
    'BSA': {'name': 'Brasileirão', 'country': 'Brazil', 'flag': '🇧🇷'},
    'CL': {'name': 'Champions League', 'country': 'Europe', 'flag': '🇪🇺'},
    'EC': {'name': 'Euro Championship', 'country': 'Europe', 'flag': '🇪🇺'},
    'WC': {'name': 'World Cup', 'country': 'World', 'flag': '🏆'},
  };
}
