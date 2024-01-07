// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patikmobile/api/static_variables.dart';
import 'package:patikmobile/assets/mainColors.dart';
import 'package:patikmobile/locale/ChangeLanguage.dart';
import 'package:patikmobile/models/user_roles.dart';
import 'package:patikmobile/pages/login.dart';
import 'package:patikmobile/providers/loginProvider.dart';
import 'package:patikmobile/providers/mainProvider.dart';
import 'package:patikmobile/widgets/customAlertDialog.dart';
import 'package:patikmobile/widgets/icon_button.dart';
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.chevron_left_outlined))
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
              ListTile(
                title: const Text('Home'),
                selected: _selectedIndex == 0,
                onTap: () {
                  // Update the state of the app
                  _onItemTapped(0);
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Business'),
                selected: _selectedIndex == 1,
                onTap: () {
                  // Update the state of the app
                  _onItemTapped(1);
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('School'),
                selected: _selectedIndex == 2,
                onTap: () {
                  // Update the state of the app
                  _onItemTapped(2);
                  // Then close the drawer
                },
              ),
              ListTile(
                title: Text('logout'.tr),
                selected: _selectedIndex == 2,
                onTap: () {
                  // Update the state of the app
                  loginProvider.logout(context);
                  // Then close the drawer
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
