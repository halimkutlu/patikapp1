// ignore_for_file: prefer_const_constructors, use_function_type_syntax_for_parameters, must_be_immutable, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:sizer/sizer.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool loading = false;
  @override
  void initState() {
    StaticVariables.setChangeHandler(() {
      setState(() {
        loading = StaticVariables.loading;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !loading
        ? Container()
        : Scaffold(
            body: Container(
            decoration:
                BoxDecoration(color: Color.fromARGB(204, 224, 224, 224)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Image.asset(
                  'lib/assets/img/logo.png',
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
                Text(AppLocalizations.of(context).translate("181"))
              ],
            ),
          ));
  }
}

class LoadingOverlay extends StatelessWidget with ChangeNotifier {
  OverlayEntry? _overlay;

  LoadingOverlay(BuildContext context, {super.key}) {
    StaticVariables.setChangeHandler(() {
      if (StaticVariables.loading) {
        show(context);
      } else {
        hide();
      }
    });
    notifyListeners();
  }

  void show(BuildContext context) {
    if (_overlay == null) {
      _overlay = OverlayEntry(
        // replace with your own layout
        builder: (context) => ColoredBox(
          color: Color(0x80000000),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(_overlay!);
    }
  }

  void hide() {
    _overlay!.remove();
    _overlay!.dispose();
    _overlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: AlignmentDirectional.center,
        child: _overlay == null
            ? Container()
            : Overlay(
                initialEntries: [_overlay!],
              ));
  }
}
