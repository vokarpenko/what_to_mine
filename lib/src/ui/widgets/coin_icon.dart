import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'coin_icon_assets.dart';

class CoinIcon extends StatelessWidget {
  final String tag;
  final String? coinId;

  const CoinIcon(this.tag, {this.coinId, super.key});

  Widget _placeholder() => CircleAvatar(
    radius: 17.5,
    child: Text(
      tag.isEmpty ? '?' : tag.substring(0, tag.length > 2 ? 2 : tag.length),
      style: const TextStyle(fontSize: 12),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final asset = coinIconAssets[coinId];
    return SizedBox(
      width: 35,
      height: 35,
      child: asset == null
          ? _placeholder()
          : asset.endsWith('.svg')
          ? SvgPicture.asset(
              asset,
              placeholderBuilder: (_) => _placeholder(),
              errorBuilder: (_, _, _) => _placeholder(),
            )
          : Image.asset(
              asset,
              fit: BoxFit.contain,
              cacheWidth: 96,
              cacheHeight: 96,
              errorBuilder: (_, _, _) => _placeholder(),
            ),
    );
  }
}
