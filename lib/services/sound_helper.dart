// ignore_for_file: non_constant_identifier_names

import 'package:audioplayers/audioplayers.dart';

Future<void> PlayAudio(String? audio) async {
  final player = AudioPlayer();

  await player.play(
    UrlSource(audio!),
    volume: 500,
  );
}
