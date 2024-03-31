// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:just_audio/just_audio.dart';

AudioPlayer player = AudioPlayer();
Future<void> PlayAudio(String? audio) async {
  // Create a player
  try {
    Platform.isIOS
        ? await player.setAsset(audio!)
        : await player.setFilePath(audio!);
    await player.play();
  } catch (e) {
    player = AudioPlayer();
  }
}
