import 'dart:convert';

/// Supports JSON array strings, comma-separated defines, and Flutter's string
/// representation of a JSON array passed through --dart-define-from-file.
/// Flutter interpolates non-string define values rather than JSON-encoding them.
List<String> parseWhatToMineApiKeys(String value) {
  final input = value.trim();
  if (input.isEmpty) return const [];
  if (input.startsWith('[')) {
    if (!input.endsWith(']')) {
      throw const FormatException('Invalid API key list');
    }
    Object? decoded;
    if (input.contains('"')) {
      try {
        decoded = jsonDecode(input);
      } on FormatException {
        throw const FormatException('Invalid API key list');
      }
    } else {
      // Native JSON arrays become "[token1, token2]" in Flutter's build defines.
      // Numeric-looking string tokens also lose their quotes in this form.
      decoded = input.substring(1, input.length - 1).split(',');
    }
    if (decoded is! List || decoded.any((value) => value is! String)) {
      throw const FormatException('API keys must be strings');
    }
    return normalizeWhatToMineApiKeys(decoded.cast<String>());
  }
  return normalizeWhatToMineApiKeys(input.split(','));
}

List<String> normalizeWhatToMineApiKeys(Iterable<String> values) {
  final keys = <String>{};
  for (final value in values) {
    final key = value.trim();
    if (key.isEmpty) continue;
    if (RegExp(r'[\s,\[\]{}"\x27]').hasMatch(key)) {
      // Do not include credentials in an exception or diagnostic output.
      throw const FormatException('Invalid API key list');
    }
    keys.add(key);
  }
  return List.unmodifiable(keys);
}
