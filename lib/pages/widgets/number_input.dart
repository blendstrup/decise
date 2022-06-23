import 'package:decise/state/number_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class NumberInputField extends StatefulWidget {
  const NumberInputField({
    Key? key,
    required this.labelText,
    required this.provider,
    required this.value,
  }) : super(key: key);

  final String labelText;
  final StateProvider provider;
  final int value;

  @override
  _NumberInputFieldState createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<NumberInputField> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          widget.labelText,
          style: textTheme.headline6,
        ),
        SizedBox(
          width: 120,
          child: Consumer(
            builder: (context, ref, _) => FocusScope(
              child: Focus(
                onFocusChange: (focus) {
                  // The value only gets reset to the last digit, meaning that if the previous number was
                  // bigger than 9, it will not be correctly reset when losing focus
                  if (controller.text.isEmpty)
                    controller.text = widget.value.toString();
                },
                child: TextField(
                  controller: controller,
                  cursorColor: Colors.yellow[600],
                  decoration: InputDecoration.collapsed(hintText: ''),
                  style: textTheme.headline4!.copyWith(fontSize: 46),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [LengthLimitingTextInputFormatter(4)],
                  autocorrect: false,
                  enableSuggestions: false,
                  onChanged: (str) {
                    if (str.isNotEmpty) {
                      int val = int.tryParse(str) ?? 0;
                      ref.read(widget.provider).state = val;
                      ref.read(numberProvider.notifier).resetList();
                      Hive.box('decise').put(widget.labelText, val);
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
