import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../data/wheel_item.dart';
import '../state/wheel_state.dart';

import 'widgets/bottom_bar.dart';

class WheelPage extends ConsumerStatefulWidget {
  const WheelPage({Key? key}) : super(key: key);

  @override
  WheelPageState createState() => WheelPageState();
}

class WheelPageState extends ConsumerState<WheelPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final items = ref.watch(wheelItemsProvider);
    bool isAnimating = ref.watch(isAnimatingProvider);
    final usedItems = ref.watch(usedItemsProvider);
    final wheelController = ref.watch(wheelControllerProvider);

    return Scaffold(
      backgroundColor: Colors.red[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 350,
                  child: FortuneWheel(
                    selected: wheelController.stream,
                    animateFirst: false,
                    onAnimationStart: () => isAnimating = true,
                    onAnimationEnd: () => isAnimating = false,
                    physics: CircularPanPhysics(),
                    onFling: () => spinWheel(
                      items,
                      isAnimating,
                      wheelController,
                      usedItems,
                    ),
                    indicators: [
                      FortuneIndicator(
                        alignment: Alignment.topCenter,
                        child: Transform.translate(
                          offset: const Offset(0.0, -34.0),
                          child: Icon(
                            Icons.arrow_drop_down,
                            size: 80,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                    items: [
                      for (WheelItem item in items)
                        FortuneItem(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(
                              item.text,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: usedItems.contains(items.indexOf(item))
                                  ? textTheme.headline6!.copyWith(
                                      fontSize: 16,
                                      decoration: TextDecoration.lineThrough,
                                    )
                                  : textTheme.headline6!.copyWith(fontSize: 16),
                            ),
                          ),
                          style: FortuneItemStyle(
                            borderWidth: 0,
                            color: getColor(items, item),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomBar(
        color: Colors.red[600],
        primaryOnTap: () => spinWheel(
          items,
          isAnimating,
          wheelController,
          usedItems,
        ),
        primaryChild: Icon(
          Icons.rotate_right,
          color: Colors.black54,
        ),
        showSecondaryButton: true,
        secondaryOnTap: () => Navigator.of(context).pushNamed('/wheelEdit'),
        secondaryChild: Icon(
          Icons.edit,
          color: Colors.black54,
        ),
      ),
    );
  }

  void spinWheel(
    List<WheelItem> items,
    bool isAnimating,
    StreamController<int> wheelController,
    List<int> usedItems,
  ) {
    int value = Random().nextInt(items.length);
    if (!isAnimating) {
      wheelController.add(value);
      usedItems.add(value);
      print('used items: $usedItems');
    }
  }

  Color getColor(List<WheelItem> items, WheelItem item) {
    if (items.length.isOdd && items.indexOf(item) == 0) return Colors.black38;

    if (items.indexOf(item).isEven)
      //return Colors.red.shade600;
      return Colors.black12;
    else
      //return Colors.red.shade400;
      return Colors.black26;
  }
}
