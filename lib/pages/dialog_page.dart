import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:patikmobile/assets/style/mainColors.dart';

class DialogPage extends StatefulWidget {
  const DialogPage({super.key});

  @override
  State<DialogPage> createState() => _DialogPageState();
}

class _DialogPageState extends State<DialogPage> {
  @override
  Widget build(BuildContext context) {
    return CardSwiper(
      numberOfCardsDisplayed: 3,
      backCardOffset: Offset(-25, -40),
      cardsCount: 4,
      cardBuilder: (context, index, percentThresholdX, percentThresholdY) =>
          Container(
        decoration: BoxDecoration(
            color: MainColors.primaryColor,
            borderRadius: BorderRadius.all(Radius.circular(40)),
            border: Border.all(width: 0.2)),
        alignment: new Alignment(0, 0),
      ),
      isLoop: false,
    );
  }
}
