// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/providers/dialogCategoriesProvider.dart';
import 'package:patikmobile/services/sound_helper.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class DialogPage extends StatefulWidget {
  final String? dialogId;
  const DialogPage({super.key, this.dialogId});

  @override
  State<DialogPage> createState() => _DialogPageState();
}

class _DialogPageState extends State<DialogPage> {
  late DialogCategoriesProvider provider;
  List<WidgetsToImageController> controllers = [];
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    provider = Provider.of<DialogCategoriesProvider>(context, listen: false);
    provider.dialogPageInit(widget.dialogId, context);
  }

  Future<ShareResult> getCapture(WidgetsToImageController contrller) async {
    final box = context.findRenderObject() as RenderBox?;
    var capture = await contrller.capture();
    var xfiles = <XFile>[
      XFile.fromData(capture!,
          length: capture!.length,
          mimeType: "image/png",
          name: "dialog.png",
          lastModified: DateTime.now())
    ];
    return await Share.shareXFiles(xfiles,
        text: AppLocalizations.of(context).translate("157"),
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: MainColors.backgroundColor),
      backgroundColor: MainColors.backgroundColor,
      body: Consumer<DialogCategoriesProvider>(
          builder: (context, provider, child) {
        if (!provider.isDialogListLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                    child: ListView.builder(
                        itemCount: provider.dialogs.length,
                        itemBuilder: (context, index) {
                          controllers.add(WidgetsToImageController());
                          return Padding(
                            padding: EdgeInsets.only(
                                top: 0.8.h,
                                left: 8.0.w,
                                right: 8.0.w,
                                bottom: 0.7.h),
                            child: Stack(children: [
                              WidgetsToImage(
                                  controller: controllers[index],
                                  child: Container(
                                    height: 13.h,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(238, 255, 255, 255),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                                0.5), // Gölge rengi ve opaklık
                                            spreadRadius: 1, // Yayılma alanı
                                            blurRadius:
                                                1, // Bulanıklık yarıçapı
                                            offset: const Offset(
                                                0, 1), // Gölge offset
                                          ),
                                        ],
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 11.w, right: 11.w),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Center(
                                                      child: AutoSizeText(
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    provider.dialogs[index]
                                                        .dialogAppLng!,
                                                    style: TextStyle(
                                                      fontSize: 1.7.h,
                                                    ),
                                                  )),
                                                  AutoSizeText(
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    provider
                                                        .dialogs[index].word!,
                                                    style: TextStyle(
                                                        fontSize: 1.9.h,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  provider.dialogs[index]
                                                              .wordT ==
                                                          null
                                                      ? Container()
                                                      : AutoSizeText(
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                          provider
                                                              .dialogs[index]
                                                              .wordT!,
                                                          style: TextStyle(
                                                              fontSize: 1.9.h,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        )
                                                ]),
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                              Positioned(
                                top: 0.5.h,
                                right: 0,
                                child: Column(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        PlayAudio(
                                            provider.dialogs[index].audio);
                                      },
                                      icon: Container(
                                        width: 10.w,
                                        height: 4.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape
                                              .circle, // Daire şeklinde bir kutu oluştur
                                          color: Colors
                                              .red, // Dairenin arkaplan rengi
                                        ),
                                        child: Icon(
                                          Icons.volume_up_outlined,
                                          size: 2.5.h,
                                          color: Colors.white, // İkonun rengi
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await getCapture(controllers[index]);
                                      },
                                      icon: Container(
                                        width: 10.w,
                                        height: 4.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape
                                              .circle, // Daire şeklinde bir kutu oluştur
                                          color: Colors
                                              .red, // Dairenin arkaplan rengi
                                        ),
                                        child: Icon(
                                          Icons.share_outlined,
                                          size: 2.5.h,
                                          color: Colors.white, // İkonun rengi
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ]),
                          );
                        }))
              ],
            )
          ],
        );
      }),
    );
  }
}
