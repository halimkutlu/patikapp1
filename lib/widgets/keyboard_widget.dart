// ignore_for_file: unused_local_variable, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, unnecessary_null_comparison, prefer_const_constructors, unused_element

import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:patikmobile/main.dart';
import 'package:patikmobile/providers/games_providers/fill_the_blank_game.dart';
import 'package:sizer/sizer.dart';

class KeyCharInformation {
  late int Index = 0;
  late String Char;
  late int Count = 0;

  KeyCharInformation(this.Index, this.Count, this.Char);
}

class NumericKeypad extends StatefulWidget {
  final FillTheBlankGameProvider provider;

  const NumericKeypad({super.key, required this.provider});

  @override
  State<NumericKeypad> createState() => _NumericKeypadState();
}

class _NumericKeypadState extends State<NumericKeypad> {
  String? word = "";
  TextEditingController? controller = TextEditingController();
  Uint8List? image = Uint8List(0);
  bool processDone = false;
  final Widget _horizontalPadding = const SizedBox(
    width: 10.0,
  );
  final Widget _verticalPadding = const SizedBox(height: 10.0);
  late int buttonCount = 25;
  late Map<String, int> wordCharList = <String, int>{};
  late List<KeyCharInformation> keyList = [];

  @override
  void initState() {
    super.initState();
    startProcedures(widget.provider);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (processDone)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xffe8eaed),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          height: 6.h,
                          width: 20.w,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(222, 255, 255, 255),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: SvgPicture.memory(
                            image!,
                            height: 19.h,
                          ),
                        ),
                        Container(
                          height: 6.h,
                          width: 60.w,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(222, 255, 255, 255),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Column(
                            children: [
                              Center(
                                child: Text(word! + "(kalkacak)"),
                              ),
                              Center(child: Text(controller!.text)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _verticalPadding,
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xffe8eaed),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _horizontalPadding,
                            _buildButton(0),
                            _horizontalPadding,
                            _buildButton(1),
                            _horizontalPadding,
                            _buildButton(2),
                            _horizontalPadding,
                            _buildButton(3),
                            _horizontalPadding,
                            _buildButton(4),
                            _horizontalPadding,
                            _buildButton(5),
                            _horizontalPadding,
                            _buildButton(6),
                            _horizontalPadding,
                            _buildButton(7),
                            _horizontalPadding,
                            _buildButton(8),
                            _horizontalPadding,
                          ],
                        ),
                        _verticalPadding,
                        Row(
                          children: [
                            _horizontalPadding,
                            _buildButton(9),
                            _horizontalPadding,
                            _buildButton(10),
                            _horizontalPadding,
                            _buildButton(11),
                            _horizontalPadding,
                            _buildButton(12),
                            _horizontalPadding,
                            _buildButton(13),
                            _horizontalPadding,
                            _buildButton(14),
                            _horizontalPadding,
                            _buildButton(15),
                            _horizontalPadding,
                            _buildButton(16),
                            _horizontalPadding,
                            _buildButton(17),
                            _horizontalPadding,
                          ],
                        ),
                        _verticalPadding,
                        Row(
                          children: [
                            _horizontalPadding,
                            _buildButton(18),
                            _horizontalPadding,
                            _buildButton(19),
                            _horizontalPadding,
                            _buildButton(20),
                            _horizontalPadding,
                            _buildButton(21),
                            _horizontalPadding,
                            _buildButton(22),
                            _horizontalPadding,
                            _buildButton(23),
                            _horizontalPadding,
                            _buildButton(24),
                            _horizontalPadding,
                            _buildButton(-1,
                                text: '⌫',
                                onPressed: _backspace,
                                wideRow: true),
                            _horizontalPadding,
                          ],
                        ),
                        _verticalPadding,
                      ],
                    ),
                  ),
                ),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     _horizontalPadding,
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Container(
                //           width: 12.w,
                //           child: _buildButton(-1, text: '⌫', onPressed: _enter)),
                //     )
                //   ],
                // )
              ],
            ),
          ),
      ],
    );
  }

  // Individual keys
  Widget _buildButton(int buttonIndex,
      {String? text, VoidCallback? onPressed, bool? wideRow = false}) {
    int count = 0;
    if (buttonIndex >= 0) {
      KeyCharInformation keyButton =
          keyList.firstWhere((element) => element.Index == buttonIndex);
      count = keyButton.Count;
      text = keyButton.Char;
    }
    return Expanded(
      child: Container(
        width: 29.56,
        height: 40,
        padding: const EdgeInsets.only(top: 4, left: 0, right: 3, bottom: 5),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          shadows: [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 0,
              offset: Offset(0, 1),
              spreadRadius: 0,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextButton(
                onPressed: onPressed ??
                    (isDisabled(buttonIndex, text, count)
                        ? null
                        : () => _input(text!)),
                child: Text(
                  isDisabled(buttonIndex, text, count) ? "" : text!,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 2.3.h,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    height: 0.02,
                  ),
                ),
                // textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 5.96,
              height: 30.h,
              child: Text(
                count > 1 ? count.toString() : "",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Color(0xFFE8233D),
                  fontSize: 10,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  height: 0,
                ),
              ),
            ),
          ],
        ),
      ),
      // child: Container(
      //   height: 6.5.h,
      //   width: 5.w,
      //   decoration: const BoxDecoration(
      //     color: Color.fromARGB(222, 255, 255, 255),
      //     borderRadius: BorderRadius.all(Radius.circular(10.0)),
      //   ),
      //   child: TextButton(
      //     onPressed: onPressed ??
      //         (isDisabled(buttonIndex, text, count)
      //             ? null
      //             : () => _input(text!)),
      //     child: Center(
      //       child: Column(
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           count > 1
      //               ? Row(
      //                   mainAxisAlignment: MainAxisAlignment.end,
      //                   children: [
      //                     Text(
      //                       count > 1 ? count.toString() : "",
      //                       style:
      //                           TextStyle(fontSize: 1.4.h, color: Colors.red),
      //                     ),
      //                   ],
      //                 )
      //               : Container(),
      //           Text(
      //             isDisabled(buttonIndex, text, count) ? "" : text!,
      //             style: TextStyle(color: Colors.black),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  void _input(String text) async {
    int isMatch = await checkWordIsCorrect(text);
    if (isMatch == 1) {
      setState(() {
        final value = controller!.text + text;
        controller!.text = value;
      });
    } else if (isMatch == 2) {
      setState(() {
        final value = controller!.text + text;
        controller!.text = value;
        return;
      });
      startProcedures(widget.provider);
    }
  }

  Future<int> checkWordIsCorrect(String text) async {
    var isValid = false;
    var dumText = "";
    if (text.isNotEmpty) {
      dumText = controller!.text + text;
      for (var i = 0; i < dumText.length; i++) {
        if (dumText[i] == word![i]) {
          isValid = true;
        } else {
          isValid = false;
        }
      }
    }

    if (isValid) {
      if (word!.length == dumText.length) {
        print("bitti");
        return 2;
      } else {
        print("ddaha bitmedi ama dogru");
        return 1;
      }
    } else {
      await widget.provider.wrongCharacter();
      return 0;
    }
  }

  void _backspace() {
    setState(() {
      final value = controller!.text;
      if (value.isNotEmpty) {
        controller!.text = value.substring(0, value.length - 1);
      }
    });
  }

  bool isDisabled(int index, String? text, int count) {
    if (index < 0) return false;
    return count == 0 ||
        text == null ||
        text.isEmpty ||
        text.allMatches(controller!.text).length == count;
  }

  void startProcedures(FillTheBlankGameProvider provider) async {
    controller = TextEditingController();
    wordCharList = <String, int>{};
    keyList = [];
    processDone = false;

    await widget.provider.takeWord();
    if (provider.selectedWord != null) {
      image = provider.selectedWord!.imageBytes;
      word = provider.selectedWord!.word;

      setState(() {
        List<String>.generate(word!.length, (index) => word![index]).forEach(
            (x) => wordCharList[x] =
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
      processDone = true;
    }
  }
}
