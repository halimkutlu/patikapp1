// ignore_for_file: unused_local_variable, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, unnecessary_null_comparison

import 'dart:core';

import 'package:flutter/material.dart';

class KeyCharInformation {
  late int Index = 0;
  late String Char;
  late int Count = 0;

  KeyCharInformation(this.Index, this.Count, this.Char);
}

class NumericKeypad extends StatefulWidget {
  final TextEditingController controller;
  final String word;

  const NumericKeypad(
      {super.key, required this.controller, required this.word});

  @override
  State<NumericKeypad> createState() => _NumericKeypadState();
}

class _NumericKeypadState extends State<NumericKeypad> {
  late int buttonCount = 15;
  late Map<String, int> wordCharList = <String, int>{};
  late List<KeyCharInformation> keyList;

  @override
  void initState() {
    super.initState();
    setState(() {
      List<String>.generate(widget.word.length, (index) => widget.word[index])
          .forEach((x) => wordCharList[x] =
              !wordCharList.containsKey(x) ? 1 : (wordCharList[x]! + 1));

      keyList = Iterable<int>.generate(buttonCount)
          .toList()
          .map((r) => KeyCharInformation(r, 0, ''))
          .toList();

      wordCharList.forEach((key, value) {
        var list = keyList.where((element) => element.Count == 0).toList();
        if (list.isNotEmpty) {
          KeyCharInformation keyButton =
              (keyList.where((element) => element.Count == 0).toList()
                    ..shuffle())
                  .first;
          if (keyButton != null) {
            keyButton.Char = key;
            keyButton.Count = value;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildButton(0),
            _buildButton(1),
            _buildButton(2),
            _buildButton(3),
          ],
        ),
        Row(
          children: [
            _buildButton(4),
            _buildButton(5),
            _buildButton(6),
            _buildButton(7),
          ],
        ),
        Row(
          children: [
            _buildButton(8),
            _buildButton(9),
            _buildButton(10),
            _buildButton(11),
          ],
        ),
        Row(
          children: [
            _buildButton(12),
            _buildButton(13),
            _buildButton(14),
            _buildButton(15, text: '⌫', onPressed: _backspace),
          ],
        ),
      ],
    );
  }

  // Individual keys
  Widget _buildButton(int buttonIndex,
      {String? text, VoidCallback? onPressed}) {
    int count = 0;
    if (text == null || text.isEmpty) {
      KeyCharInformation keyButton =
          keyList.firstWhere((element) => element.Index == buttonIndex);
      count = keyButton.Count;
      text = keyButton.Char;
    }
    return Expanded(
      child: TextButton(
        onPressed:
            onPressed ?? (isDisabled(text, count) ? null : () => _input(text!)),
        child: Text(isDisabled(text, count) ? "" : text!),
      ),
    );
  }

  void _input(String text) {
    setState(() {
      final value = widget.controller.text + text;
      widget.controller.text = value;
    });
  }

  void _backspace() {
    setState(() {
      final value = widget.controller.text;
      if (value.isNotEmpty) {
        widget.controller.text = value.substring(0, value.length - 1);
      }
    });
  }

  bool isDisabled(String? text, int count) {
    if (text == '⌫') return false;
    return count == 0 ||
        text == null ||
        text!.isEmpty ||
        text.allMatches(widget.controller.text).length == count;
  }
}
