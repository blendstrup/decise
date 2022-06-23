import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/number_state.dart';

import 'widgets/number_input.dart';
import 'widgets/repeat_toggle.dart';
import 'widgets/bottom_bar.dart';

class NumberPage extends StatelessWidget {
  const NumberPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.yellow[300],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 60),
                  Consumer(
                    builder: (context, ref, _) => Text(
                      ref.watch(numberProvider),
                      style: textTheme.headline2!.copyWith(
                        fontSize: 96,
                        color: ref.watch(numberColorProvider),
                      ),
                    ),
                  ),
                  SizedBox(height: 80),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Consumer(
                        builder: (context, ref, _) => NumberInputField(
                          labelText: 'min',
                          provider: minValProvider,
                          value: ref.watch(minValProvider),
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, _) => NumberInputField(
                          labelText: 'max',
                          provider: maxValProvider,
                          value: ref.watch(maxValProvider),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  RepeatToggle(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Consumer(
          builder: (context, ref, _) => AppBottomBar(
            color: Colors.yellow[600],
            primaryOnTap: () async {
              if (ref.read(numberAnimatingProvider) == true) return;

              //TODO ref.watch(numberAnimatingProvider) = true;
              await ref.read(numberProvider.notifier).refreshNumber();
              //TODO ref.watch(numberAnimatingProvider) = false;
            },
            primaryChild: Icon(
              Icons.tag,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
