// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:just_audio/just_audio.dart';

Future<void> PlayAudio(String? audio) async {
  final player = AudioPlayer(); // Create a player
  Platform.isIOS
      ? await player.setAsset(audio!)
      : await player.setFilePath(audio!);
  player.play();
}
