// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, unused_element, use_build_context_synchronously
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/user_roles.dart';
import 'package:patikmobile/pages/about_app.dart';
import 'package:patikmobile/pages/change_password.dart';
import 'package:patikmobile/pages/feedback.dart';
import 'package:patikmobile/pages/remove_ads.dart';
import 'package:patikmobile/pages/select_language.dart';
import 'package:patikmobile/pages/select_learn_language.dart';
import 'package:patikmobile/providers/loginProvider.dart';
import 'package:patikmobile/providers/dashboardProvider.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/widgets/icon_button.dart';
import 'package:patikmobile/widgets/menu_item.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class Dashboard extends StatefulWidget {
  final int? selectedPageIndex;
  const Dashboard(this.selectedPageIndex, {super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<WidgetsToImageController> controllers = [];

  late DashboardProvider mainProvider;
  @override
  void initState() {
    super.initState();
    mainProvider = Provider.of<DashboardProvider>(context, listen: false);
    mainProvider.init();
    if (widget.selectedPageIndex != null && widget.selectedPageIndex! > 0) {
      Future.delayed(Duration(milliseconds: 500),
          () => mainProvider.changeTab(widget.selectedPageIndex!));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<ShareResult> getCapture(WidgetsToImageController contrller) async {
    var capture = await contrller.capture();
    var xfiles = <XFile>[
      XFile.fromData(capture!,
          length: capture.length,
          mimeType: "image/png",
          name: "dialog.png",
          lastModified: DateTime.now())
    ];
    return await Share.shareXFiles(xfiles,
        text: AppLocalizations.of(context).translate("157"));
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = Provider.of<DashboardProvider>(context);
    final loginProvider = Provider.of<LoginProvider>(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MainColors.backgroundColor,
        ),
        body: Center(
          child: mainProvider.pages[mainProvider.selectedTab],
        ),
        drawer: Drawer(
          backgroundColor: MainColors.backgroundColor,
          elevation: 1,
          width: double.infinity,

          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: Column(
            // Important: Remove any padding from the ListView.
            children: [
              SizedBox(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(200),
                        bottomRight: Radius.circular(200)),
                    color: MainColors.primaryColor,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Container(
                          color: MainColors.primaryColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  iconSize: 40,
                                  icon: Icon(Icons.chevron_left_outlined)),
                              IconButton(
                                  onPressed: () {
                                    loginProvider.logout(context);
                                  },
                                  iconSize: 30,
                                  icon: Icon(Icons.logout))
                            ],
                          ),
                        ),
                      ),
                      Container(
                        transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 20.w,
                              decoration: const ShapeDecoration(
                                color: Color(0xFFD7D6D6),
                                shape: OvalBorder(),
                              ),
                              child: Image.asset(
                                'lib/assets/img/avatar.png',
                                width: 10.w,
                              ),
                            ),
                            AutoSizeText(mainProvider.userName),
                            AutoSizeText(
                              maxLines: 1,
                              mainProvider.nameLastname,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            mainProvider.roleid == UserRole.free
                                ? AutoSizeText(
                                    maxLines: 1,
                                    AppLocalizations.of(context)
                                        .translate("72"),
                                    style: TextStyle(
                                      color: Color(0xFF605E5E),
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                    ))
                                : AutoSizeText(
                                    maxLines: 1,
                                    UserRole.getRoleDescriptionFromId(
                                        mainProvider.roleid)),
                            mainProvider.roleid == UserRole.free
                                ? CustomIconButton(
                                    onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => RemoveAds())),
                                    textSize: 20,
                                    height: 8.w,
                                    textInlinePadding: 3.w,
                                    colors: Colors.red,
                                    name: AppLocalizations.of(context)
                                        .translate("73"),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: ListView(
                //padding: EdgeInsets.only(bottom: 1.h),
                shrinkWrap: true,
                children: <Widget>[
                  MenuItem(
                      logo: 'lib/assets/img/user_language.png',
                      text: AppLocalizations.of(context).translate("27"),
                      centerWidget: Text(AppLocalizations.of(context)
                          .translateLngName(StorageProvider.appLanguge)),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SelectLanguage(
                                  dashboard: true,
                                )));
                      }),
                  MenuItem(
                      logo: 'lib/assets/img/learn_language.png',
                      text: AppLocalizations.of(context).translate("28"),
                      centerWidget: Text(AppLocalizations.of(context)
                          .translateLngName(StorageProvider.learnLanguge)),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SelectLearnLanguage(
                                  noReturn: true,
                                )));
                      }),
                  MenuItem(
                      logo: 'lib/assets/img/key.png',
                      text: AppLocalizations.of(context).translate("75"),
                      centerWidget: Text(""),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ChangePassword()));
                      }),
                  MenuItem(
                      logo: 'lib/assets/img/privacy.png',
                      text: AppLocalizations.of(context).translate("77"),
                      centerWidget: Text(""),
                      onTap: () {}),
                  // MenuItem(
                  //     logo: 'lib/assets/img/star_.png',
                  //     text: AppLocalizations.of(context).translate("69"),
                  //     centerWidget: Text(""),
                  //     onTap: () {}),
                  MenuItem(
                      logo: 'lib/assets/img/mail.png',
                      text: AppLocalizations.of(context).translate("80"),
                      centerWidget: Text(""),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => FeedbackPage()));
                      }),
                  MenuItem(
                      logo: 'lib/assets/img/mail.png',
                      text: AppLocalizations.of(context).translate("78"),
                      centerWidget: Text(""),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AboutApp()));
                      }),
                  Padding(padding: EdgeInsets.only(bottom: 10))
                ],
              ))
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: MainColors.primaryColor,
          currentIndex: mainProvider.selectedTab,
          onTap: (index) => mainProvider.changeTab(index),
          selectedItemColor: Colors.black,
          showUnselectedLabels: true,
          unselectedItemColor: Color(0xff7E7B7B),
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: AppLocalizations.of(context).translate("104"),
                backgroundColor: MainColors.primaryColor),
            BottomNavigationBarItem(
                icon: Image.asset(
                  'lib/assets/img/graduate.png',
                  width: 5.5.w,
                  height: 5.5.w,
                  fit: BoxFit.cover,
                ),
                label: AppLocalizations.of(context).translate("105"),
                backgroundColor: MainColors.primaryColor),
            BottomNavigationBarItem(
                icon: Image.asset(
                  'lib/assets/img/muscle.png',
                  width: 5.5.w,
                  height: 5.5.w,
                  fit: BoxFit.cover,
                ),
                label: AppLocalizations.of(context).translate("106"),
                backgroundColor: MainColors.primaryColor),
            BottomNavigationBarItem(
                icon: Image.asset(
                  'lib/assets/img/chat.png',
                  width: 5.5.w,
                  height: 5.5.w,
                  fit: BoxFit.cover,
                ),
                label: AppLocalizations.of(context).translate("99"),
                backgroundColor: MainColors.primaryColor),
          ],
        ),
      ),
    );
  }
}
