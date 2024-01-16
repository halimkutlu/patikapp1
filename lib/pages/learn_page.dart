// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/providers/categoriesProvider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({Key? key}) : super(key: key);

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  late CategoriesProvider categoriesProvider;

  @override
  void initState() {
    super.initState();
    categoriesProvider =
        Provider.of<CategoriesProvider>(context, listen: false);
    categoriesProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainColors.backgroundColor,
      body: Consumer<CategoriesProvider>(
        builder: (context, provider, child) {
          provider.categoryList
              .sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

          var categoriesWithoutOrder = provider.categoryList
              .where((category) => category.order == null)
              .toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: provider.categoryList.length +
                      categoriesWithoutOrder.length,
                  itemBuilder: (context, index) {
                    if (index < categoriesWithoutOrder.length) {
                      var category = categoriesWithoutOrder[index];
                      return ListTile(
                        title: AutoSizeText(category.categoryName!),
                        subtitle:
                            AutoSizeText('Total Count: ${category.totalCount}'),
                      );
                    } else {
                      var categoryIndex = index - categoriesWithoutOrder.length;
                      var category = provider.categoryList[categoryIndex];
                      if (categoryIndex == 0 ||
                          category.order !=
                              provider.categoryList[categoryIndex - 1].order) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8.0.w, top: 1.h, bottom: 1.h),
                                  child: Text(
                                    '${category.categoryOrderName}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 13.h,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: provider.categoryList.length,
                                itemBuilder: (context, horizontalIndex) {
                                  var horizontalCategory =
                                      provider.categoryList[horizontalIndex];
                                  if (horizontalCategory.order ==
                                      category.order) {
                                    return categoryBox(
                                      "",
                                      horizontalCategory.categoryName!,
                                      horizontalCategory.categoryWordCount!,
                                      horizontalCategory.totalCount!,
                                      horizontalCategory.orderColor!,
                                    );
                                  } else {
                                    return SizedBox.shrink(); // Boş bir widget
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        return SizedBox.shrink(); // Boş bir widget
                      }
                    }
                  },
                ),
              ),
              boxArea(), // boxArea'yi Column'un dışına çıkardık
            ],
          );
        },
      ),
    );
  }

  Widget categoryBox(
      String image, String name, int wordCount, int totalCount, int color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 30.w,
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 0.2),
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 4), // Gölgenin konumu (x, y)
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: Icon(
                Icons.logo_dev,
                color: Color(color),
                size: 5.h,
              ),
            ),
            Center(
              child: AutoSizeText(
                name,
                style: TextStyle(
                  fontSize: 1.3.h,
                  fontWeight: FontWeight.bold,
                  color: Color(color),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoSizeText(
                      wordCount.toString(),
                      style: TextStyle(
                        fontSize: 1.3.h,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    AutoSizeText(
                      " / ",
                      style: TextStyle(
                        fontSize: 1.3.h,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AutoSizeText(
                      totalCount.toString(),
                      style: TextStyle(
                        fontSize: 1.3.h,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget boxArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          box(
            AppLocalizations.of(context).translate("101"),
            MainColors.boxColor1,
            categoriesProvider.getLernedWordCount.toString(),
            'lib/assets/img/ilearned.png',
          ),
          box(
            AppLocalizations.of(context).translate("102"),
            MainColors.boxColor2,
            categoriesProvider.getRepeatedWordCount.toString(),
            'lib/assets/img/repeat.png',
          ),
          box(
            AppLocalizations.of(context).translate("103"),
            MainColors.boxColor3,
            categoriesProvider.getWorkHardCount.toString(),
            'lib/assets/img/sun.png',
          ),
        ],
      ),
    );
  }

  Widget box(String text, Color color, String value, String iconUrl) {
    return Column(
      children: [
        Container(
          height: 3.h,
          width: 25.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(3),
                  bottomRight: Radius.circular(3)),
              color: color,
              border: Border.all(width: 3, color: Colors.black38)),
          child: Center(
              child: AutoSizeText(
            text,
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
        ),
        Container(
          height: 8.h,
          width: 23.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
              color: color,
              border: Border.all(width: 3, color: Colors.black38)),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0.1.h),
                child: Image.asset(
                  iconUrl,
                  width: 6.w,
                  height: 3.h,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.5.h, right: 2.w, left: 2.w),
                child: Container(
                  color: Colors.white,
                  child: Center(
                      child: AutoSizeText(
                    value,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
