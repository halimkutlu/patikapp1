// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:patikmobile/services/sound_helper.dart';
import 'package:sizer/sizer.dart';

Widget ErrorImage() {
  //PlayAudio("lib/assets/sound/error.mp3", true);
  return Container(
    color: const Color.fromARGB(42, 255, 255, 255),
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
