// ignore_for_file: prefer_const_constructors

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BoxWidget extends StatefulWidget {
  final String text;
  final Color color;
  final String value;
  final String iconUrl;
  final VoidCallback onTap;

  const BoxWidget(
      {super.key,
      required this.text,
      required this.color,
      required this.value,
      required this.iconUrl,
      required this.onTap});

  @override
  State<BoxWidget> createState() => _BoxWidgetState();
}

class _BoxWidgetState extends State<BoxWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Column(
        children: [
          Container(
            width: 25.w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(3),
                    bottomRight: Radius.circular(3)),
                color: widget.color,
                border: Border.all(width: 3, color: Colors.black38)),
            child: Center(
                child: AutoSizeText(
              maxLines: 1,
              widget.text,
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
          ),
          Container(
            height: 8.h,
            width: 23.w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                color: widget.color,
                border: Border.all(width: 3, color: Colors.black38)),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 0.1.h),
                  child: Image.asset(
                    widget.iconUrl,
                    width: 6.w,
                    height: 3.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0.5.h, right: 2.w, left: 2.w),
                  child: Container(
                    color: Colors.white,
                    child: Center(
                        child: AutoSizeText(
                      widget.value,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
