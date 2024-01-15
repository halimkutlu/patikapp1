// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MenuItem extends StatefulWidget {
  final String logo;
  final String? text;
  final Widget? centerWidget;
  final VoidCallback? onTap;

  const MenuItem(
      {super.key,
      required this.logo,
      this.text,
      this.centerWidget,
      this.onTap});

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 18.0, right: 18, bottom: 5, top: 5),
        child: Container(
          height: 5.h,
          color: Colors.white,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 1.5.h),
                  child: Image.asset(
                    widget.logo,
                    fit: BoxFit.cover,
                    height: 3.3.h,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 1.5.h),
                  child: AutoSizeText(
                    widget.text!,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 1.h),
                  child: widget.centerWidget,
                ),
                Padding(
                    padding: EdgeInsets.only(left: 0.h),
                    child: Icon(Icons.chevron_right)),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
