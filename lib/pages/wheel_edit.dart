import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/wheel_item.dart';
import '../state/wheel_state.dart';

import 'widgets/bottom_bar.dart';
import 'widgets/platform_dialog.dart';

class WheelEditPage extends ConsumerStatefulWidget {
  const WheelEditPage({Key? key}) : super(key: key);

  @override
  _WheelEditPageState createState() => _WheelEditPageState();
}

class _WheelEditPageState extends ConsumerState<WheelEditPage> {
  late ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<WheelItem> items = ref.watch(wheelItemsProvider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.red[300],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              controller: controller,
              child: Column(
                children: [
                  SizedBox(height: 60),
                  Text(
                    'wheel items',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 40),
                  for (var item in items)
                    WheelEditItem(
                      item: item,
                      items: items,
                      key: ValueKey(item.id),
                    ),
                  if (items.length > 7) SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: AppBottomBar(
          color: Colors.red[600],
          showPrimaryButton: false,
          showSecondaryButton: true,
          secondaryChild: Icon(
            Icons.add,
            color: Colors.black54,
          ),
          secondaryOnTap: () async {
            if (items.length < 20) {
              ref.read(wheelItemsProvider.notifier).addItem();
              controller.jumpTo(controller.position.maxScrollExtent);
            } else {
              showPlatformDialog(
                context,
                'Too many items',
                'You can\'t have more than 20 items in the wheel :(',
              );
            }
          },
          backHeroTag: 'wheelEditBack',
          primaryHeroTag: 'wheelEditPrimary',
          secondaryHeroTag: 'wheelEditSecondary',
        ),
      ),
    );
  }
}

class WheelEditItem extends ConsumerStatefulWidget {
  const WheelEditItem({
    Key? key,
    required this.item,
    required this.items,
  }) : super(key: key);

  final WheelItem item;
  final List<WheelItem> items;

  @override
  _WheelEditItemState createState() => _WheelEditItemState();
}

class _WheelEditItemState extends ConsumerState<WheelEditItem> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.item.text);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.black12,
      child: ListTile(
        title: TextField(
          controller: controller,
          cursorColor: Colors.red[600],
          decoration: InputDecoration.collapsed(hintText: ''),
          style: Theme.of(context).textTheme.headline6,
          autocorrect: false,
          enableSuggestions: false,
          onChanged: (str) => ref
              .read(wheelItemsProvider.notifier)
              .editItem(widget.item.id, str),
        ),
        trailing: IconButton(
          splashRadius: 24,
          icon: Icon(Icons.delete),
          onPressed: () {
            if (widget.items.length > 2) {
              ref.read(wheelItemsProvider.notifier).removeItem(widget.item);
            } else {
              showPlatformDialog(
                context,
                'Too few items',
                'You need to have at least 2 items in the wheel :(',
              );
            }
          },
        ),
      ),
    );
  }
}
