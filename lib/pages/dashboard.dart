// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, unused_element
import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/user_roles.dart';
import 'package:patikmobile/pages/about_app.dart';
import 'package:patikmobile/pages/change_password.dart';
import 'package:patikmobile/pages/feedback.dart';
import 'package:patikmobile/pages/select_language.dart';
import 'package:patikmobile/pages/select_learn_language.dart';
import 'package:patikmobile/providers/loginProvider.dart';
import 'package:patikmobile/providers/dashboardProvider.dart';
import 'package:patikmobile/providers/storageProvider.dart';
import 'package:patikmobile/widgets/icon_button.dart';
import 'package:patikmobile/widgets/menu_item.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class Dashboard extends StatefulWidget {
  final int? selectedPageIndex;
  const Dashboard(this.selectedPageIndex, {super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

bool a = true;

class _DashboardState extends State<Dashboard> {
  late DashboardProvider mainProvider;
  @override
  void initState() {
    super.initState();
    mainProvider = Provider.of<DashboardProvider>(context, listen: false);
    mainProvider.init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
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
                height: 43.h,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: Divider.createBorderSide(context,
                          color: Colors.black, width: 0.3),
                    ),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(200),
                        bottomRight: Radius.circular(200)),
                    color: MainColors.primaryColor,
                  ),
                  child: Center(
                      child: Column(
                    children: [
                      Container(
                        color: MainColors.primaryColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.chevron_left_outlined)),
                            IconButton(
                                onPressed: () {
                                  loginProvider.logout(context);
                                },
                                icon: Icon(Icons.logout))
                          ],
                        ),
                      ),
                      Container(
                        transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                        child: Column(
                          children: [
                            Container(
                              height: 10.h,
                              width: 25.w,
                              decoration: const ShapeDecoration(
                                color: Color(0xFFD7D6D6),
                                shape: OvalBorder(),
                              ),
                              child: Image.asset(
                                'lib/assets/img/avatar.png',
                                height: 10.h,
                                width: 10.w,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(mainProvider.userName)),
                            ),
                            Center(
                                child: Text(
                              mainProvider.nameLastname,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: mainProvider.roleid == UserRole.free
                                      ? Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Sınırlı kullanım ',
                                                style: TextStyle(
                                                  color: Color(0xFF605E5E),
                                                  fontSize: 14,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w500,
                                                  height: 0.10,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'Ücretsiz sürüm',
                                                style: TextStyle(
                                                  color: Color(0xFFE8233D),
                                                  fontSize: 14,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.w400,
                                                  height: 0.10,
                                                ),
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.center,
                                        )
                                      : Text(UserRole.getRoleDescriptionFromId(
                                          mainProvider.roleid)),
                                )),
                            CustomIconButton(
                              textSize: 80,
                              height: 3.5.h,
                              textInlinePadding: 20,
                              width: 3,
                              colors: Colors.red,
                              name:
                                  AppLocalizations.of(context).translate("73"),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
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
                      logo: 'lib/assets/img/internet.png',
                      text: AppLocalizations.of(context).translate("74"),
                      centerWidget: CustomIconButton(
                        textSize: 30,
                        textInlinePadding: 25,
                        width: 4,
                        colors: Colors.red,
                        name: AppLocalizations.of(context).translate("73"),
                      ),
                      onTap: () {}),
                  MenuItem(
                      logo: 'lib/assets/img/key.png',
                      text: AppLocalizations.of(context).translate("22"),
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
                  MenuItem(
                      logo: 'lib/assets/img/star_.png',
                      text: AppLocalizations.of(context).translate("69"),
                      centerWidget: Text(""),
                      onTap: () {}),
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
                ],
              ))
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: MainColors.primaryColor,
          currentIndex: mainProvider.selectedTab,
          onTap: (index) => () {},
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
                  height: 2.4.h,
                  fit: BoxFit.cover,
                ),
                label: AppLocalizations.of(context).translate("105"),
                backgroundColor: MainColors.primaryColor),
            BottomNavigationBarItem(
                icon: Image.asset(
                  'lib/assets/img/muscle.png',
                  width: 5.5.w,
                  height: 2.4.h,
                  fit: BoxFit.cover,
                ),
                label: AppLocalizations.of(context).translate("106"),
                backgroundColor: MainColors.primaryColor),
            BottomNavigationBarItem(
                icon: Image.asset(
                  'lib/assets/img/chat.png',
                  width: 5.5.w,
                  height: 2.4.h,
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
