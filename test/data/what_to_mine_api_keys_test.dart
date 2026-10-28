import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:what_to_mine/src/data/client/what_to_mine_api_keys.dart';

void main() {
  test(
    'parses JSON arrays, Flutter define arrays and comma-separated lists',
    () {
      for (final input in [
        '["first", "second"]',
        '[first, second]',
        'first,second',
      ]) {
        expect(parseWhatToMineApiKeys(input), ['first', 'second']);
      }
      final file =
          jsonDecode('{"WHAT_TO_MINE_API_KEYS":["first","second"]}')
              as Map<String, dynamic>;
      // This is how Flutter's extractDartDefines interpolates a native array.
      expect(parseWhatToMineApiKeys('${file['WHAT_TO_MINE_API_KEYS']}'), [
        'first',
        'second',
      ]);
    },
  );

  test(
    'normalizes whitespace, empty entries and duplicate tokens preserving order',
    () {
      expect(parseWhatToMineApiKeys('[ first, , second, first ]'), [
        'first',
        'second',
      ]);
      expect(
        normalizeWhatToMineApiKeys([' first ', '', 'second', 'first', ' ']),
        ['first', 'second'],
      );
      expect(parseWhatToMineApiKeys('[]'), isEmpty);
      expect(parseWhatToMineApiKeys(' '), isEmpty);
    },
  );

  test('Flutter native arrays can contain numeric-looking string tokens', () {
    expect(parseWhatToMineApiKeys('${['123', '456']}'), ['123', '456']);
  });

  test(
    'rejects malformed configuration without including any token in the error',
    () {
      for (final input in [
        '[secret-token',
        '{"key":"secret-token"}',
        '["secret-token", 123]',
        '["secret-token", ["nested"]]',
        'secret-token\nheader',
        '"secret-token"',
      ]) {
        expect(
          () => parseWhatToMineApiKeys(input),
          throwsA(
            isA<FormatException>().having(
              (error) => error.toString(),
              'redacted error',
              isNot(contains('secret-token')),
            ),
          ),
        );
      }
    },
  );
}
