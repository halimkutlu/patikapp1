import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/providers/dialogCategoriesProvider.dart';
import 'package:patikmobile/services/sound_helper.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

class DialogPage extends StatefulWidget {
  final String? dialogId;
  const DialogPage({super.key, this.dialogId});

  @override
  State<DialogPage> createState() => _DialogPageState();
}

class _DialogPageState extends State<DialogPage> {
  late DialogCategoriesProvider provider;
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
                          return Padding(
                            padding: EdgeInsets.only(
                                top: 0.8.h,
                                left: 8.0.w,
                                right: 8.0.w,
                                bottom: 0.7.h),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(238, 255, 255, 255),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                          0.5), // Gölge rengi ve opaklık
                                      spreadRadius: 1, // Yayılma alanı
                                      blurRadius: 1, // Bulanıklık yarıçapı
                                      offset:
                                          const Offset(0, 1), // Gölge offset
                                    ),
                                  ],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Center(
                                              child: AutoSizeText(
                                            provider.dialogs[index].wordA!,
                                            style: TextStyle(
                                              fontSize: 1.9.h,
                                            ),
                                          )),
                                          AutoSizeText(
                                            provider.dialogs[index].word!,
                                            style: TextStyle(
                                                fontSize: 1.9.h,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          AutoSizeText(
                                            provider.dialogs[index].wordT!,
                                            style: TextStyle(
                                                fontSize: 1.9.h,
                                                fontWeight: FontWeight.w400),
                                          )
                                        ]),
                                  ),
                                  Column(
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
                                        onPressed: () {
                                          Share.share(
                                              'check out my website https://example.com \n test');
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
                                ],
                              ),
                            ),
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
