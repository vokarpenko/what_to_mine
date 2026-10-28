import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A one-shot toss of the existing coin artwork. Multiple thin gold planes
/// give the coin an edge when it turns sideways; no animated bitmap is needed.
class SplashCoinToss extends StatelessWidget {
  static const duration = Duration(milliseconds: 1900);
  final Animation<double> animation;
  final ImageProvider image;
  final double size;
  final double maxRise;

  const SplashCoinToss({
    required this.animation,
    required this.image,
    this.size = 128,
    this.maxRise = 140,
    super.key,
  });

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: Image(
      image: image,
      width: size,
      height: size,
      excludeFromSemantics: true,
    ),
    builder: (context, coin) {
      final t = animation.value;
      var y = 0.0;
      var x = 0.0;
      var spin = 0.0;
      var lean = 0.0;
      var squash = 0.0;
      var airborne = 0.0;
      if (t < .08) {
        squash = Curves.easeIn.transform(t / .08) * .07;
        y = squash * size * .7;
      } else if (t < .78) {
        final flight = (t - .08) / .70;
        airborne = math.sin(math.pi * flight);
        y = size * .049 * (1 - flight) - 4 * maxRise * flight * (1 - flight);
        x = 8 * airborne;
        spin = 4 * math.pi * flight;
        lean = .13 * math.sin(2 * math.pi * flight);
        squash = .07 * (1 - (flight / .1).clamp(0, 1));
      } else if (t < .86) {
        final landing = math.sin(math.pi * (t - .78) / .08);
        squash = .11 * landing;
        y = squash * size * .5;
      } else if (t < .94) {
        y = -9 * math.sin(math.pi * (t - .86) / .08);
      }
      // At rest the PNG has its exact original size, position and orientation,
      // matching Android's static launch screen before the toss begins.
      final isResting = t == 0 || t >= .94;
      final depth = 2.4 * airborne;
      Matrix4 projection(double z) => Matrix4.identity()
        ..setEntry(3, 2, .0018)
        ..rotateZ(lean)
        ..rotateY(spin)
        ..translateByDouble(0, 0, z, 1);
      final front = projection(math.cos(spin) >= 0 ? -depth : depth);
      if (math.cos(spin) < 0) {
        // The reverse face uses the same emblem, rather than mirrored letters.
        front.scaleByDouble(-1, 1, 1, 1);
      }
      final shadowColor = Theme.of(context).colorScheme.shadow;
      final shadowFade =
          (t / .08).clamp(0.0, 1.0) * (1 - ((t - .90) / .04).clamp(0.0, 1.0));
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size - 2,
            child: Opacity(
              opacity: isResting ? 0 : .14 * (1 - .65 * airborne) * shadowFade,
              child: Transform.scale(
                scaleX: 1 + airborne * .35,
                child: Container(
                  width: size * .62,
                  height: 9,
                  decoration: BoxDecoration(
                    color: shadowColor,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 6 + 4 * airborne,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(x, y),
            child: Transform.scale(
              scaleX: 1 + squash * .65,
              scaleY: 1 - squash,
              child: SizedBox(
                key: const ValueKey('splash_coin'),
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!isResting && airborne > .001)
                      for (final z in [-depth, 0.0, depth])
                        Transform(
                          alignment: Alignment.center,
                          transform: projection(z),
                          child: Container(
                            width: size - 1,
                            height: size - 1,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFFD451), Color(0xFFD56B00)],
                              ),
                            ),
                          ),
                        ),
                    Transform(
                      key: const ValueKey('splash_coin_front'),
                      alignment: Alignment.center,
                      transform: front,
                      child: coin,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
