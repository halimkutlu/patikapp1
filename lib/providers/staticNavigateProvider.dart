// ignore_for_file: file_names

import 'package:flutter/material.dart';

NavigatorState of(
  BuildContext context, {
  bool rootnavigator = false,
}) {
  // handles the case where the input context is a navigator element.
  NavigatorState? navigator;
  if (context is StatefulElement && context.state is NavigatorState) {
    navigator = context.state as NavigatorState;
  }
  if (rootnavigator) {
    navigator =
        context.findRootAncestorStateOfType<NavigatorState>() ?? navigator;
  } else {
    navigator = navigator ?? context.findAncestorStateOfType<NavigatorState>();
  }
  return navigator!;
}
