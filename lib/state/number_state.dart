import 'dart:math' show Random;
import 'package:flutter/material.dart' show Color, Colors;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final numberProvider = StateNotifierProvider.autoDispose<Number, String>(
  (ref) => Number(ref: ref),
);

class Number extends StateNotifier<String> {
  Number({required this.ref}) : super('#');

  List<int> numList = [];
  final Ref ref;
  final Random rng = Random();

  void resetList() => numList = [];

  String getNumber() {
    int min = ref.read(minValProvider);
    int max = ref.read(maxValProvider);
    bool repeating = ref.read(repeatingProvider);

    if (min > max) return '?';

    if (repeating) return (min + rng.nextInt(max + 1 - min)).toString();

    if (numList.isEmpty)
      numList = List<int>.generate(
        max - min + 1,
        (i) => i + min,
      )..shuffle();

    return numList.removeLast().toString();
  }

  Future<void> refreshNumber() async {
    ref.watch(numberAnimatingProvider.notifier).state = true;

    int min = ref.read(minValProvider);
    int max = ref.read(maxValProvider);
    Set<int> col = {};

    if (min > max)
      return await Future.delayed(
        const Duration(milliseconds: 0),
        () => state = getNumber(),
      );

    if (range(min: min, max: max) >= 5)
      while (col.length < 5) col.add(min + rng.nextInt(max + 1 - min));
    else
      while (col.length < range(min: min, max: max))
        col.add(min + rng.nextInt(max + 1 - min));

    for (int i in col)
      await Future.delayed(
        Duration(milliseconds: 100),
        () => state = i.toString(),
      );

    await Future.delayed(
      const Duration(milliseconds: 100),
      () => state = getNumber(),
    );

    ref.watch(numberAnimatingProvider.notifier).state = false;
  }

  int range({required int min, required int max, int step = 1}) {
    var len;
    if (max.isNegative)
      len = (max - min) - 1;
    else
      len = (max - min) + 1;

    if (len < 0) len *= -1;
    return len;
  }
}

final numberAnimatingProvider = StateProvider<bool>((ref) => false);

final numberColorProvider = StateProvider<Color>(
  (ref) => ref.watch(numberAnimatingProvider) ? Colors.black26 : Colors.black54,
);

final maxValProvider = StateProvider<int>(
  (ref) => Hive.box('decise').get('max') ?? 10,
);

final minValProvider = StateProvider<int>(
  (ref) => Hive.box('decise').get('min') ?? 0,
);

final repeatingProvider = StateProvider<bool>(
  (ref) => Hive.box('decise').get('repeating') ?? true,
);
