import 'package:flutter_test/flutter_test.dart';
import 'package:what_to_mine/src/domain/gpu/gpu_catalog_order.dart';
import '../test_objects_factory.dart';

List<String> ordered(List<String> names) {
  final cards =
      names
          .map(
            (name) => TestObjectsFactory.createGtx1080().rebuild(
              (builder) => builder
                ..id = name
                ..name = name
                ..marketingName = name,
            ),
          )
          .toList()
        ..sort(compareGpuByRecency);
  return cards.map((gpu) => gpu.marketingName).toList();
}

void main() {
  test(
    'GeForce generations and model tiers descend independently of alphabet',
    () {
      final newestFirst = [
        'GeForce RTX 5090',
        'GeForce RTX 5080',
        'GeForce RTX 5070 Ti',
        'GeForce RTX 5070',
        'GeForce RTX 5060 Ti',
        'GeForce RTX 5060',
        'GeForce RTX 4090',
        'GeForce RTX 4060',
        'GeForce RTX 3090',
        'GeForce RTX 2080 Ti',
        'GeForce GTX 1660 Super',
        'GeForce GTX 1080 Ti',
        'GeForce GTX 1080',
        'GeForce GTX 980',
        'GeForce GTX 780',
      ];
      expect(ordered(newestFirst.reversed.toList()), newestFirst);
    },
  );

  test('Radeon generations and suffixes descend, including RX 9000', () {
    final newestFirst = [
      'Radeon RX 9070 XT',
      'Radeon RX 9070',
      'Radeon RX 7900 XTX',
      'Radeon RX 7900 XT',
      'Radeon RX 7900 GRE',
      'Radeon RX 7800 XT',
      'Radeon RX 6900 XT',
      'Radeon RX 6600 XT',
      'Radeon RX 5700 XT',
      'Radeon VII',
      'Radeon RX Vega 64',
      'Radeon RX 590',
      'Radeon RX 480',
      'Radeon R9 Fury',
      'Radeon R9 390',
      'Radeon R9 290X',
    ];
    expect(ordered(newestFirst.reversed.toList()), newestFirst);
  });

  test(
    'Ti Super, Ti and Super refine a tier, without promoting a generation',
    () {
      final newestFirst = [
        'RTX 4070 Ti Super',
        'RTX 4070 Ti',
        'RTX 4070 Super',
        'RTX 4070',
        'RTX 3070 Ti',
      ];
      expect(ordered(newestFirst.reversed.toList()), newestFirst);
    },
  );

  test(
    'both vendors share generation-year priority, rather than model numbers',
    () {
      expect(
        ordered([
          'Radeon RX 7900 XTX',
          'GeForce RTX 5090',
          'Radeon RX 9070 XT',
          'GeForce RTX 4090',
          'Radeon RX 6900 XT',
        ]),
        [
          'GeForce RTX 5090',
          'Radeon RX 9070 XT',
          'GeForce RTX 4090',
          'Radeon RX 7900 XTX',
          'Radeon RX 6900 XT',
        ],
      );
    },
  );

  test('case and attached suffixes are recognized', () {
    expect(ordered(['gtx 1080', 'GTX1080Ti', 'rx7900xt', 'RX7900XTX']), [
      'RX7900XTX',
      'rx7900xt',
      'GTX1080Ti',
      'gtx 1080',
    ]);
  });

  test(
    'unknown and workstation families remain available in natural name order',
    () {
      expect(
        ordered([
          'RTX 5000 Ada',
          'Mystery 100',
          'GeForce GTX 1080',
          'Mystery 9',
          'RTX A5000',
          'GeForce RTX 5090',
        ]),
        [
          'GeForce RTX 5090',
          'GeForce GTX 1080',
          'Mystery 9',
          'Mystery 100',
          'RTX 5000 Ada',
          'RTX A5000',
        ],
      );
    },
  );
}
