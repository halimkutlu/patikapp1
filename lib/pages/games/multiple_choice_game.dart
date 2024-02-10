// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:patikmobile/pages/dashboard.dart';
import 'package:patikmobile/providers/games_providers/multiple_choice_game_provider.dart';
import 'package:patikmobile/services/ad_helper.dart';
import 'package:patikmobile/widgets/customAlertDialogOnlyOk.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../assets/style/mainColors.dart';

class MultipleChoiceGame extends StatefulWidget {
  const MultipleChoiceGame({super.key});

  @override
  State<MultipleChoiceGame> createState() => _MultipleChoiceGameState();
}

class _MultipleChoiceGameState extends State<MultipleChoiceGame> {
  BannerAd? _bannerAd;
  late MultipleChoiceGameProvider multipleChoiceGameProvider;

  @override
  void dispose() {
    _bannerAd?.dispose();
    if (multipleChoiceGameProvider.interstitialAd != null) {
      multipleChoiceGameProvider.interstitialAd!.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    multipleChoiceGameProvider =
        Provider.of<MultipleChoiceGameProvider>(context, listen: false);
    multipleChoiceGameProvider.init(context);

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        await askToGoMainMenu(func: () {
          setState(() {
            // matchWithPictureGameProvide.resetData();
            // imageList = [];
            // wordList = [];
          });
        });
      },
      child: Scaffold(
          backgroundColor: MainColors.backgroundColor,
          body: Consumer<MultipleChoiceGameProvider>(
              builder: (context, provider, child) {
            if (!provider.wordsLoaded!) {
              // Eğer kelimeler yüklenmediyse bir yükleniyor ekranı göster
              return const Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                if (_bannerAd != null)
                  Positioned(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble() * 2,
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  ),
                Column(
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.2), // Gölge rengi ve opaklık
                                spreadRadius: 2, // Yayılma alanı
                                blurRadius: 1, // Bulanıklık yarıçapı
                                offset: const Offset(0, 2), // Gölge offset
                              ),
                            ],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                        child: SvgPicture.memory(
                          provider.selectedWord!.imageBytes!,
                          height: 15.h,
                        ),
                      ),
                    )),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 8.0.w, right: 8.0.w, bottom: 3.h, top: 1.h),
                        child: Container(
                          decoration: BoxDecoration(
                              color: MainColors.primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                      0.2), // Gölge rengi ve opaklık
                                  spreadRadius: 2, // Yayılma alanı
                                  blurRadius: 1, // Bulanıklık yarıçapı
                                  offset: const Offset(0, 2), // Gölge offset
                                ),
                              ],
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20))),
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              provider.selectedWord!.wordAppLng!,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 2.h),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        child: ListView.builder(
                            itemCount: provider.selectedAnswerList!.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  // Seçilen cevabı kontrol etme işlemleri burada yapılabilir
                                  // Örneğin, provider üzerinden kontrol edilebilir
                                  provider.checkAnswer(
                                      provider.selectedAnswerList![index]);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 8.0.w, right: 8.0.w, bottom: 2.3.h),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                                0.2), // Gölge rengi ve opaklık
                                            spreadRadius: 2, // Yayılma alanı
                                            blurRadius:
                                                1, // Bulanıklık yarıçapı
                                            offset: const Offset(
                                                0, 2), // Gölge offset
                                          ),
                                        ],
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20))),
                                    padding: const EdgeInsets.all(16),
                                    // Arka plan rengi
                                    child: Center(
                                      child: Text(
                                        provider
                                            .selectedAnswerList![index].answer,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 1.7.h), // Metin rengi
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }))
                  ],
                ),
                if (provider.errorAccuried == true) ...[
                  Positioned(child: ErrorImage()),
                ],
                if (provider.successAccuried == true) ...[
                  Positioned(child: SuccessImage()),
                ],
              ],
            );
          })),
    );
  }

  Widget ErrorImage() {
    return Container(
      color: const Color.fromARGB(42, 255, 255, 255),
      child: Center(
        child: Image.asset(
          'lib/assets/img/error_image.png',
          width: 42.w,
          height: 20.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget SuccessImage() {
    return Container(
      color: const Color.fromARGB(42, 255, 255, 255),
      child: Center(
        child: Image.asset(
          'lib/assets/img/success_image.png',
          width: 42.w,
          height: 20.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> askToGoMainMenu({VoidCallback? func}) async {
    await CustomAlertDialogOnlyConfirm(context, () {
      if (func != null) {
        func();
      }
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Dashboard(0)),
          (Route<dynamic> route) => false);
    },
        "warning".tr,
        "Eğitimi bitirmek istiyormusunuz. Gelişmeleriniz kaydedilmeyecektir.",
        ArtSweetAlertType.info,
        "ok".tr);
  }
}
