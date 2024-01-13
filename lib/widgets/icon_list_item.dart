// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class IconListItem extends StatefulWidget {
  final String? imageStr;
  final String? Text;
  final VoidCallback? onTap;

  const IconListItem(
      {super.key, required this.imageStr, required this.Text, this.onTap});

  @override
  State<IconListItem> createState() => _IconListItemState();
}

class _IconListItemState extends State<IconListItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap ?? () {},
      child: Padding(
        padding: EdgeInsets.only(left: 2.h, right: 2.h, top: 1.h),
        child: Container(
          height: 6.5.h,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              border: Border.all(color: Colors.black, width: 0.1)),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Image.asset(
                widget.imageStr ?? 'lib/assets/graduate.png',
                width: 7.w,
                height: 3.h,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Text(
                widget.Text ?? "Yeni Kelimeler Öğren",
                style: TextStyle(fontSize: 2.5.h, fontWeight: FontWeight.w500),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
