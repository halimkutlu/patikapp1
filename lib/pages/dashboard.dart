// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/assets/mainColors.dart';
import 'package:patikmobile/locale/ChangeLanguage.dart';
import 'package:patikmobile/models/user_roles.dart';
import 'package:patikmobile/pages/about_app.dart';
import 'package:patikmobile/pages/faq.dart';
import 'package:patikmobile/pages/change_password.dart';
import 'package:patikmobile/pages/feedback.dart';
import 'package:patikmobile/pages/forgotPassword.dart';
import 'package:patikmobile/pages/login.dart';
import 'package:patikmobile/pages/select_language.dart';
import 'package:patikmobile/pages/select_learn_language.dart';
import 'package:patikmobile/providers/loginProvider.dart';
import 'package:patikmobile/providers/mainProvider.dart';
import 'package:patikmobile/widgets/customAlertDialog.dart';
import 'package:patikmobile/widgets/icon_button.dart';
import 'package:patikmobile/widgets/menu_item.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

bool a = true;

class _DashboardState extends State<Dashboard> {
  late MainProvider mainProvider;
  @override
  void initState() {
    super.initState();
    mainProvider = Provider.of<MainProvider>(context, listen: false);
    mainProvider.init();
  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
    final mainProvider = Provider.of<MainProvider>(context);
    final loginProvider = Provider.of<LoginProvider>(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: Text("test")),
        body: Center(
          child: _widgetOptions[_selectedIndex],
        ),
        drawer: Drawer(
          backgroundColor: MainColors.backgroundColor,
          elevation: 1,

          width: double.infinity,

          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 50.h,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: Divider.createBorderSide(context,
                          color: Colors.black, width: 0.3),
                    ),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100)),
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
                        height: 10.h,
                        width: 25.w,
                        decoration: const ShapeDecoration(
                          color: Color(0xFFD7D6D6),
                          shape: OvalBorder(),
                        ),
                        child: Image.asset(
                          'lib/assets/avatar.png',
                          height: 10,
                          width: 10,
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
                                : mainProvider.roleid == UserRole.premium
                                    ? Text("Premium")
                                    : mainProvider.roleid == UserRole.qr
                                        ? Text("QR")
                                        : mainProvider.roleid == UserRole.admin
                                            ? Text("Admin")
                                            : Text(""),
                          )),
                      CustomIconButton(
                        height: 25,
                        textInlinePadding: 20,
                        width: 3,
                        colors: Colors.red,
                        name: "Satın Al",
                      )
                    ],
                  )),
                ),
              ),
              MenuItem(
                  logo: 'lib/assets/user_language.png',
                  text: "Kullanıcı Dili",
                  centerWidget: Text(mainProvider.useLanguageName),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SelectLanguage(
                              dashboard: true,
                            )));
                  }),
              MenuItem(
                  logo: 'lib/assets/learn_language.png',
                  text: "Öğrenme Dili",
                  centerWidget: Text(mainProvider.learnLanguageName),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SelectLearnLanguage()));
                  }),
              MenuItem(
                  logo: 'lib/assets/internet.png',
                  text: "Çevrimdışı Mod",
                  centerWidget: CustomIconButton(
                    textSize: 60,
                    textInlinePadding: 25,
                    width: 4,
                    colors: Colors.red,
                    name: "Satın Al",
                  ),
                  onTap: () {}),
              MenuItem(
                  logo: 'lib/assets/key.png',
                  text: "Şifre Değiştir",
                  centerWidget: Text(""),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChangePassword()));
                  }),
              MenuItem(
                  logo: 'lib/assets/privacy.png',
                  text: "Gizlilik Politikası",
                  centerWidget: Text(""),
                  onTap: () {}),
              MenuItem(
                  logo: 'lib/assets/star_.png',
                  text: "Uygulamayı deperlendir",
                  centerWidget: Text(""),
                  onTap: () {}),
              MenuItem(
                  logo: 'lib/assets/mail.png',
                  text: "Geri Bildirim",
                  centerWidget: Text(""),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => FeedbackPage()));
                  }),
              MenuItem(
                  logo: 'lib/assets/mail.png',
                  text: "Uygulama Hakkında",
                  centerWidget: Text(""),
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => AboutApp()));
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
