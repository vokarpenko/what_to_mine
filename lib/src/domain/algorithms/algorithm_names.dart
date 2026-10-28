// Normalize spelling without merging different versions of an algorithm.
String algorithmKey(String name) =>
    name.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

int hashCoefficient(double hashesPerSecond) {
  if (hashesPerSecond >= 1000000000) return 1000000000;
  if (hashesPerSecond >= 1000000) return 1000000;
  if (hashesPerSecond >= 1000) return 1000;
  return 1;
}
