import 'package:flutter/material.dart';
import 'package:patikmobile/assets/mainColors.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:sizer/sizer.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: Color.fromARGB(204, 224, 224, 224)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Image.asset(
                'lib/assets/logo.png',
                fit: BoxFit.cover,
              )),
              Container(
                height: 10.h,
                width: 40.w,
                child: const LoadingIndicator(
                  indicatorType: Indicator.ballPulse,
                  colors: [Colors.red, Color(0xffFFD600)],
                  strokeWidth: 1,
                ),
              ),
              Text("Lütfen bekleyiniz")
            ],
          ),
        ),
      ),
    );
  }
}
