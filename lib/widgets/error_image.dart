 import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

Widget ErrorImage() {
    return Container(
      color: Color.fromARGB(42, 255, 255, 255),
      child: Center(
        child: Image.asset(
          'lib/assets/img/error_image.png',
          width: 35.w,
          height: 15.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }