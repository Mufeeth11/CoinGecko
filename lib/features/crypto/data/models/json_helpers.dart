extension JsonHelpers on Map<String, dynamic> {
  double doubleAt(String key, [double fallback = 0]) {
    final value = this[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  double? nullableDoubleAt(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int intAt(String key, [int fallback = 0]) =>
      doubleAt(key, fallback.toDouble()).toInt();

  String stringAt(String key, [String fallback = '']) {
    final value = this[key];
    return value == null ? fallback : value.toString();
  }

  List<String> stringListAt(String key) {
    final value = this[key];
    if (value is! List) return const <String>[];
    return value.whereType<String>().toList();
  }

  List<double> doubleListAt(String key) {
    final value = this[key];
    if (value is! List) return const <double>[];
    return value
        .whereType<num>()
        .map((item) => item.toDouble())
        .where((item) => item.isFinite)
        .toList();
  }
}
