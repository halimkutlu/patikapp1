// ignore_for_file: non_constant_identifier_names



import 'package:just_audio/just_audio.dart';

Future<void> PlayAudio(String? audio) async {
  final player = AudioPlayer();                   // Create a player
  await player.setAsset(           // Load a URL
    audio!);                 // Schemes: (https: | file: | asset: )
  player.play();   
}
