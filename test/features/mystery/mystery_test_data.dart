import 'dart:convert';

Map<String, Object> mysteryJsonFixture() => <String, Object>{
  'id': 'alchemy-vault',
  'caseNumber': 1,
  'title': 'The Alchemy Vault',
  'category': 'Logic',
  'difficulty': 'Easy',
  'story': 'Three sealed caskets.',
  'clues': <Object>[
    <String, Object>{'id': 'c1', 'text': 'Clue one.', 'orderIndex': 0},
    <String, Object>{'id': 'c2', 'text': 'Clue two.', 'orderIndex': 1},
  ],
  'answers': <Object>[
    <String, Object>{'id': 'a1', 'text': 'The gold casket'},
    <String, Object>{'id': 'a2', 'text': 'The silver casket'},
    <String, Object>{'id': 'a3', 'text': 'The bronze casket'},
    <String, Object>{'id': 'a4', 'text': 'None of the above'},
  ],
  'correctAnswerId': 'a2',
  'explanation': 'Because silver is the only case.',
  'hints': <String>['Look at silver.'],
  'timeLimitSeconds': 60,
  'availableDate': '2026-08-01',
};

String mysteryJsonDocument([List<Map<String, Object>>? mysteries]) {
  return jsonEncode(<String, Object>{
    'mysteries': mysteries ?? <Map<String, Object>>[mysteryJsonFixture()],
  });
}

String mysteryJsonDocumentWith(Map<String, Object> mystery) {
  return jsonEncode(<String, Object>{
    'mysteries': <Object>[mystery],
  });
}