import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../state/number_state.dart';

class RepeatToggle extends ConsumerWidget {
  const RepeatToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          'repeat',
          style: textTheme.headline6,
        ),
        IconButton(
          onPressed: () {
            bool current = ref.read(repeatingProvider);
            ref.read(repeatingProvider.notifier).state = !current;
            Hive.box('decise').put('repeating', !current);
          },
          icon: Consumer(builder: (context, watch, _) {
            bool repeating = ref.watch(repeatingProvider);

            return Icon(
              repeating ? Icons.check : Icons.close,
              size: 46,
              color: Colors.black54,
            );
          }),
          iconSize: 46,
          splashRadius: 32,
        )
      ],
    );
  }
}
