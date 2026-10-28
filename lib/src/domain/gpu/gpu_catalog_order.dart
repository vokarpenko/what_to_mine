import 'gpu.dart';

/// A catalog order, not exact release dates or a performance ranking.
/// Known generation launch years group both brands; model tier and variant
/// decide the order within a family. Unknown families stay available at the end.
int compareGpuByRecency(Gpu a, Gpu b) {
  final left = _generation(a.marketingName);
  final right = _generation(b.marketingName);
  for (var i = 0; i < left.length; i++) {
    final order = right[i].compareTo(left[i]);
    if (order != 0) return order;
  }
  final name = _naturalNameOrder(a.marketingName, b.marketingName);
  return name != 0 ? name : a.id.compareTo(b.id);
}

List<int> _generation(String name) {
  final text = name.toLowerCase().replaceAllMapped(
    RegExp(r'(\d)([a-z])'),
    (match) => '${match[1]} ${match[2]}',
  );
  final geforce = RegExp(r'\b(rtx|gtx)\s*(\d{3,4})\b').firstMatch(text);
  if (geforce != null) {
    final number = int.parse(geforce[2]!);
    final family = number ~/ 100;
    final tier = number % 100;
    // RTX 4000/5000 workstation cards aren't GeForce 40/50 series.
    final year = tier >= 50
        ? (geforce[1] == 'rtx'
              ? const {20: 2018, 30: 2020, 40: 2022, 50: 2025}[family]
              : const {7: 2013, 9: 2014, 10: 2016, 16: 2018}[family])
        : null;
    if (year != null) {
      return [year, geforce[1] == 'rtx' ? 2 : 1, number, _variant(text)];
    }
  }
  final radeon = RegExp(r'\brx\s*(\d{3,4})\b').firstMatch(text);
  if (radeon != null) {
    final number = int.parse(radeon[1]!);
    final year = number >= 1000
        ? const {5: 2019, 6: 2020, 7: 2022, 9: 2025}[number ~/ 1000]
        : const {4: 2016, 5: 2017}[number ~/ 100];
    if (year != null) return [year, 1, number, _variant(text)];
  }
  if (RegExp(r'\bradeon\s+vii\b').hasMatch(text)) return [2019, 1, 0, 0];
  if (RegExp(r'\bvega\b').hasMatch(text)) {
    final number = RegExp(r'\bvega\s*(\d+)').firstMatch(text);
    return [2017, 2, int.tryParse(number?[1] ?? '') ?? 0, 0];
  }
  final r9 = RegExp(r'\br9\s*(\d{3})').firstMatch(text);
  if (r9 != null) {
    final number = int.parse(r9[1]!);
    final year = const {2: 2013, 3: 2015}[number ~/ 100];
    if (year != null) return [year, 1, number, _variant(text)];
  }
  if (RegExp(r'\br9\s+(fury|nano)\b').hasMatch(text)) {
    return [2015, 1, 400, _variant(text)];
  }
  return [0, 0, 0, 0];
}

int _variant(String name) {
  if (RegExp(r'\bti\s+super\b').hasMatch(name)) return 4;
  if (RegExp(r'\b(ti|xtx)\b').hasMatch(name)) return 3;
  if (RegExp(r'\b(super|xt)\b').hasMatch(name)) return 2;
  if (RegExp(r'\b(gre|x)\b').hasMatch(name) ||
      RegExp(r'\d{3}x\b').hasMatch(name)) {
    return 1;
  }
  return 0;
}

int _naturalNameOrder(String a, String b) {
  final parts = RegExp(r'\d+|\D+');
  final left = parts.allMatches(a.toLowerCase()).map((m) => m[0]!).toList();
  final right = parts.allMatches(b.toLowerCase()).map((m) => m[0]!).toList();
  for (var i = 0; i < left.length && i < right.length; i++) {
    final x = int.tryParse(left[i]);
    final y = int.tryParse(right[i]);
    final order = x != null && y != null
        ? x.compareTo(y)
        : left[i].compareTo(right[i]);
    if (order != 0) return order;
  }
  return left.length.compareTo(right.length);
}
