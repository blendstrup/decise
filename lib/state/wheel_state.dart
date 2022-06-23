import 'dart:async' show StreamController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:english_words/english_words.dart';
import 'package:uuid/uuid.dart';

import '../data/wheel_item.dart';
/*
final currentItemProvider = StateProvider.autoDispose((ref) {
  final currentItemController = StreamController<int>();

  ref.onDispose(() {
    currentItemController.close();
  });

  return currentItemController;
});
*/

final wheelControllerProvider = StateProvider.autoDispose((ref) {
  final wheelController = StreamController<int>();

  ref.onDispose(() {
    wheelController.sink.close();
  });

  return wheelController;
});

final isAnimatingProvider = StateProvider<bool>((ref) => false);

final usedItemsProvider = StateNotifierProvider<UsedItems, List<int>>((ref) {
  //final wheelItems = ref.watch(wheelItemsProvider);
  final usedItems = UsedItems();

  //if (usedItems.state.length > wheelItems.length) usedItems.clearItems();

  return usedItems;
});

class UsedItems extends StateNotifier<List<int>> {
  UsedItems() : super([]);

  void addItem(int val) => state = [...state, val];

  void clearItems() => state = [];
}

/*
final wheelControllerProvider = StreamProvider.autoDispose<int>((ref) {
  final wheelController = StreamController<int>();

  ref.onDispose(() {
    wheelController.close();
  });

  return wheelController.stream;
});
*/

final wheelItemsProvider =
    StateNotifierProvider<WheelItems, List<WheelItem>>((ref) {
  var hiveItems = Hive.box('decise').get('wheelItems');

  if (hiveItems != null)
    return WheelItems(List<WheelItem>.from(hiveItems));
  else
    return WheelItems();
});

const _uuid = Uuid();

class WheelItems extends StateNotifier<List<WheelItem>> {
  WheelItems([List<WheelItem>? initialItems])
      : super(initialItems ??
            [
              WheelItem(id: '1', text: 'Decise :)'),
              WheelItem(id: '2', text: 'Decise :('),
            ]);

  void addItem() {
    if (state.length < 20) {
      state = [
        ...state,
        WheelItem(
          id: _uuid.v4(),
          text: WordPair.random(safeOnly: true).asPascalCase,
        )
      ];
      Hive.box('decise').put('wheelItems', state);
    }
  }

  void removeItem(WheelItem item) {
    if (state.length > 2) {
      state = state.where((i) => i.id != item.id).toList();
      Hive.box('decise').put('wheelItems', state);
    } else {
      state = state;
    }
  }

  void editItem(String id, String newStr) {
    state = [
      for (final text in state)
        if (text.id == id)
          WheelItem(
            id: text.id,
            text: newStr,
          )
        else
          text,
    ];
    Hive.box('decise').put('wheelItems', state);
  }
}
