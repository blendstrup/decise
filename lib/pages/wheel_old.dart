/*
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../data/wheel_text.dart';
import '../state/wheel_state.dart';

import 'widgets/bottom_bar.dart';
import 'widgets/spinning_wheel.dart';

class WheelPage extends ConsumerWidget {
  const WheelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var textTheme = Theme.of(context).textTheme;
    var items = ref.watch(wheelItemsProvider);

    return Scaffold(
      backgroundColor: Colors.red[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 350,
                  child: SpinningWheel(
                    initialSpinAngle: 2 * pi - (2 * pi / items.length) / 2,
                    dividers: ref.watch(wheelItemsProvider).length,
                    child: AbsorbPointer(
                      child: Transform.rotate(
                        angle: pi / items.length,
                        child: FortuneWheel(
                          animateFirst: false,
                          physics: NoPanPhysics(),
                          indicators: [],
                          items: [
                            for (WheelText item in items)
                              FortuneItem(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Text(
                                    item.text,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.headline6!
                                        .copyWith(fontSize: 16),
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
                    ),
                    indicator: Transform.translate(
                      offset: const Offset(0.0, -34.0),
                      child: Icon(
                        Icons.arrow_drop_down,
                        size: 80,
                        color: Colors.black,
                      ),
                    ),
                    height: 350,
                    width: 350,
                    onUpdate: (val) {
                      if (val > 0 && val <= items.length)
                        ref.read(currentItemProvider).add(val);
                    },
                    onEnd: (val) => null,
                    shouldStartOrStop:
                        ref.watch(wheelControllerProvider).stream,
                  ),
                ),
                SizedBox(height: 60),
                StreamBuilder<int>(
                  stream: ref.watch(currentItemProvider).stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      int index = snapshot.data as int;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          children: [
                            Text(
                              'current',
                              style: textTheme.headline6,
                            ),
                            Text(
                              items[index - 1].text,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  textTheme.headline4!.copyWith(fontSize: 46),
                            ),
                          ],
                        ),
                      );
                    } else
                      return Container();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomBar(
        color: Colors.red[600],
        primaryOnTap: () => ref
            .read(wheelControllerProvider)
            .sink
            .add((Random().nextDouble() * 8000) + 6000),
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

  Color getColor(List<WheelText> items, WheelText item) {
    if (items.length.isOdd && items.indexOf(item) == 0) return Colors.black38;

    if (items.indexOf(item).isEven)
      //return Colors.red.shade600;
      return Colors.black12;
    else
      //return Colors.red.shade400;
      return Colors.black26;
  }
}
*/