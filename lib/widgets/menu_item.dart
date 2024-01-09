// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

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
                  padding: EdgeInsets.only(left: 18.0),
                  child: Image.asset(
                    widget.logo,
                    fit: BoxFit.cover,
                    height: 3.3.h,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 18.0),
                  child: Text(widget.text!),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: widget.centerWidget,
                ),
                Padding(
                    padding: EdgeInsets.only(left: 18.0),
                    child: Icon(Icons.chevron_right)),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
