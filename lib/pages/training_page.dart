import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:patikmobile/assets/style/mainColors.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardSwiper(
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
      ),
    );
  }
}
