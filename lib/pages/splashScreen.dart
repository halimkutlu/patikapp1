// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, file_names

// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:patikmobile/providers/splashScreenProvider.dart';
// import 'package:provider/provider.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late SplashScreenProvider splashProvider;
//   @override
//   void initState() {
//     _controller = AnimationController(
//       duration: Duration(seconds: (5)),
//       vsync: this,
//     );
//     splashProvider = Provider.of<SplashScreenProvider>(context, listen: false);
//     splashProvider.initData(context);

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Lottie.asset(
//         fit: BoxFit.cover,
//         'lib/assets/splash_lottie.json',
//         controller: _controller,
//         height: double.infinity,
//         width: double.infinity,
//         animate: true,
//         onLoaded: (composition) {
//           _controller
//             ..duration = composition.duration
//             ..forward().whenComplete(() => Navigator.of(context)
//                 .pushAndRemoveUntil(
//                     MaterialPageRoute(
//                         builder: (context) => splashProvider.page),
//                     (Route<dynamic> route) => false));
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/providers/splashScreenProvider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    final splashProvider =
        Provider.of<SplashScreenProvider>(context, listen: false);
      splashProvider.initData(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: MainColors.backgroundColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
            
              child: Image.asset(
                    'lib/assets/img/logo.png',
                    fit: BoxFit.fill,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}