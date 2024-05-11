// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/providers/boxPageProvider.dart';
import 'package:patikmobile/services/image_helper.dart';
import 'package:patikmobile/services/sound_helper.dart';
import 'package:patikmobile/widgets/box_widget.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class BoxPage extends StatefulWidget {
  final int selectedBox;
  final bool? completedGame;
  final String? dbId;
  const BoxPage(
      {super.key,
      required this.selectedBox,
      this.completedGame = false,
      this.dbId = ""});

  @override
  State<BoxPage> createState() => _BoxPageState();
}

class _BoxPageState extends State<BoxPage> {
  late BoxPageProvider boxPageProvider;
  late bool loading = true;
  @override
  void initState() {
    super.initState();
    boxPageProvider = Provider.of<BoxPageProvider>(context, listen: false);
    boxPageProvider.init(
        context, widget.selectedBox, widget.completedGame, widget.dbId);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: !widget.completedGame!
            ? widget.selectedBox == 1
                ? MainColors.boxColor1
                : widget.selectedBox == 2
                    ? MainColors.boxColor2
                    : MainColors.boxColor3
            : Color.fromARGB(255, 235, 235, 235),
      ),
      backgroundColor: !widget.completedGame!
          ? widget.selectedBox == 1
              ? MainColors.boxColor1
              : widget.selectedBox == 2
                  ? MainColors.boxColor2
                  : MainColors.boxColor3
          : Color.fromARGB(255, 235, 235, 235),
      body: Consumer<BoxPageProvider>(builder: (context, provider, child) {
        if (!provider.wordsLoaded!) {
          Future.delayed(
              Duration(seconds: 5), () => setState(() => loading = false));
          // Eğer kelimeler yüklenmediyse bir yükleniyor ekranı göster
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  CircularProgressIndicator()
                else
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context).translate("97"),
                    ),
                  )
              ],
            ),
          );
        }

        return Stack(
          children: [
            Center(
              child: Column(
                children: [
                  !widget.completedGame!
                      ? Center(
                          child: BoxWidget(
                            text: AppLocalizations.of(context)
                                .translate(widget.selectedBox == 1
                                    ? "101"
                                    : widget.selectedBox == 2
                                        ? "102"
                                        : "103"),
                            color: widget.selectedBox == 1
                                ? MainColors.boxColor1
                                : widget.selectedBox == 2
                                    ? MainColors.boxColor2
                                    : MainColors.boxColor3,
                            value: widget.selectedBox == 1
                                ? provider.getLernedWordCount.toString()
                                : widget.selectedBox == 2
                                    ? provider.getRepeatedWordCount.toString()
                                    : provider.getWorkHardCount.toString(),
                            iconUrl: widget.selectedBox == 1
                                ? 'lib/assets/img/ilearned.png'
                                : widget.selectedBox == 2
                                    ? 'lib/assets/img/repeat.png'
                                    : 'lib/assets/img/sun.png',
                            onTap: () {},
                          ),
                        )
                      : Container(),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: provider.wordListDbInformation!.length,
                      itemBuilder: (context, horizontalIndex) {
                        var item =
                            provider.wordListDbInformation![horizontalIndex];

                        return Padding(
                          padding: EdgeInsets.only(
                              left: 8.0.w, right: 8.0.w, bottom: 1.h, top: 1.h),
                          child: Container(
                            height: 5.h,
                            width: 4.w,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 4.w),
                                    child: getWordImage(
                                        item.id.toString(), item.imgLngPath,
                                        height: 4.h),
                                  ),
                                  item.wordA != null
                                      ? Column(
                                          children: [
                                            Text(item.word!),
                                            Text(item.wordA != null
                                                ? item.wordA!
                                                : ""),
                                          ],
                                        )
                                      : Text(item.word!),
                                  InkWell(
                                    onTap: () {
                                      PlayAudio(item.audio!);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.volume_up,
                                        size: 3.h,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  )
                                ]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
