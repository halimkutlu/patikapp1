// ignore_for_file: prefer_const_constructors

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String name;
  final Color? colors;
  final num height;
  final Widget? icons;
  final num width;
  final bool disable;
  final num textOutSpace_top;
  final num textOutSpace_bottom;
  final num textOutSpace_left;
  final num textInlinePadding;
  final num textOutSpace_right;
  final Color? textColor;
  final double textSize;
  CustomIconButton({
    Key? key,
    this.onTap,
    this.name = "İsim",
    this.textOutSpace_top = 70,
    this.textOutSpace_bottom = 100,
    this.textOutSpace_left = 100,
    this.textOutSpace_right = 100,
    this.textColor,
    this.textSize = 30,
    this.colors,
    this.height = 20,
    this.width = 4,
    this.icons,
    this.textInlinePadding = 200,
    this.disable = false,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: !disable ? onTap ?? () {} : null,
        child:
            // ignore: prefer_const_literals_to_create_immutables
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / textOutSpace_top,
                    left: MediaQuery.of(context).size.width / textOutSpace_left,
                    bottom: MediaQuery.of(context).size.height /
                        textOutSpace_bottom,
                    right:
                        MediaQuery.of(context).size.width / textOutSpace_right),
                child: Container(
                  decoration: BoxDecoration(
                      color: disable ? Colors.grey : colors ?? Colors.black,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  width: MediaQuery.of(context).size.width / width,
                  height: MediaQuery.of(context).size.height / height,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width /
                                textInlinePadding,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: textColor ?? Colors.white,
                                    fontSize: textSize),
                              ),
                              icons == null
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: icons)
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )));
  }
}
