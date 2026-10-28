import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:what_to_mine/src/ui/widgets/coin_icon.dart';

void main() {
  testWidgets('renders bundled WebP and SVG logos without network loaders', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              CoinIcon('PRL', coinId: '469'),
              CoinIcon('PEP', coinId: '418'),
              CoinIcon('XEL', coinId: '459'),
            ],
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(SvgPicture), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps a fallback for coins added after the bundled catalog', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CoinIcon('NEW', coinId: 'unknown')),
    );
    expect(find.text('NE'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.byType(SvgPicture), findsNothing);
  });
}
