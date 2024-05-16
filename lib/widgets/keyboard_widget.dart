// ignore_for_file: unused_local_variable, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, unnecessary_null_comparison, prefer_const_constructors, unused_element, prefer_const_literals_to_create_immutables

import 'dart:core';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/providers/games_providers/fill_the_blank_game.dart';
import 'package:patikmobile/services/image_helper.dart';
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
  Uint8List? image = Uint8List(0);

  final Widget _horizontalPadding = const SizedBox(
    width: 10.0,
  );
  final Widget _verticalPadding = const SizedBox(height: 10.0);

  @override
  void initState() {
    super.initState();
    if (!widget.provider.isTrainingGame) {
      widget.provider.startProcedures();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var g1 = AutoSizeGroup();
    return Stack(
      children: [
        if (widget.provider.processDone)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // if (kDebugMode)
                //   Center(
                //       child: Text(
                //           '${widget.provider.word!} (release modda görülmeyecek)')),
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
                          height: 20.w,
                          width: 20.w,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(222, 255, 255, 255),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: getWordImage(
                              widget.provider.selectedWord!.id.toString(),
                              widget.provider.selectedWord!.imgLngPath,
                              boxFit: BoxFit.fill),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                    group: g1,
                                    widget.provider.word!,
                                    maxLines: 1),
                                AutoSizeText(
                                    group: g1,
                                    widget
                                        .provider
                                        .selectedWordTextEditingController!
                                        .text,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20))
                              ],
                            )),
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
                            _buildButton(-1, text: '⌫', onPressed: _backspace),
                            _horizontalPadding,
                          ],
                        ),
                        _verticalPadding
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }

  // Individual keys
  Widget _buildButton(int buttonIndex,
      {String? text, VoidCallback? onPressed, bool? wideRow = false}) {
    int count = 0;
    if (buttonIndex >= 0) {
      KeyCharInformation keyButton = widget.provider.keyList
          .firstWhere((element) => element.Index == buttonIndex);
      text = keyButton.Char;
      count = keyButton.Count;
      if (text != null && text.isNotEmpty) {
        count = keyButton.Count -
            text
                .allMatches(
                    widget.provider.selectedWordTextEditingController!.text)
                .length;
      }
    }
    return Expanded(
      child: InkWell(
        onTap: onPressed ??
            (isDisabled(buttonIndex, text, count) ? null : () => _input(text!)),
        child: Container(
          width: 29.56,
          height: 40,
          padding: const EdgeInsets.only(top: 4, left: 0, right: 3, bottom: 5),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            shadows: [
              BoxShadow(
                color: Color(0x44000000),
                blurRadius: 0,
                offset: Offset(0, 1),
                spreadRadius: 0,
              )
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                  top: 0,
                  right: 0,
                  child: AutoSizeText(
                    maxLines: 1,
                    count > 1 ? count.toString() : "",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFFE8233D),
                      fontSize: 10,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      height: 0,
                    ),
                  )),
              Align(
                alignment: Alignment.center,
                child: AutoSizeText(
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  isDisabled(buttonIndex, text, count) ? "" : text!,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 2.3.h,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _input(String text) async {
    int isMatch = await checkWordIsCorrect(text);
    if (isMatch == 1) {
      setState(() {
        final value =
            widget.provider.selectedWordTextEditingController!.text + text;
        widget.provider.selectedWordTextEditingController!.text = value;
        final firstSpace = widget.provider.word?.replaceAll(
            widget.provider.selectedWordTextEditingController!.text, "");
        if (firstSpace!.startsWith(" ")) {
          widget.provider.selectedWordTextEditingController!.text += " ";
        }
      });
    } else if (isMatch == 2) {
      setState(() {
        final value =
            widget.provider.selectedWordTextEditingController!.text + text;
        widget.provider.selectedWordTextEditingController!.text = value;
        return;
      });
      widget.provider.startProcedures();
    }
  }

  Future<int> checkWordIsCorrect(String text) async {
    var isValid = false;
    var dumText = "";
    if (text.isNotEmpty) {
      dumText = widget.provider.selectedWordTextEditingController!.text + text;
      for (var i = 0; i < dumText.length; i++) {
        if (dumText[i] == widget.provider.word![i]) {
          isValid = true;
        } else {
          isValid = false;
        }
      }
    }

    if (isValid) {
      return widget.provider.word!.length == dumText.length ? 2 : 1;
    } else {
      await widget.provider.wrongCharacter();
      return 0;
    }
  }

  void _backspace() {
    setState(() {
      final value = widget.provider.selectedWordTextEditingController!.text;
      if (value.isNotEmpty) {
        widget.provider.selectedWordTextEditingController!.text =
            value.substring(0, value.length - 1);
      }
    });
  }

  bool isDisabled(int index, String? text, int count) {
    if (index < 0) return false;
    return count == 0 || text == null || text.isEmpty;
  }
}
