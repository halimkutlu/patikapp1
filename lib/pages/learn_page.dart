// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:patikmobile/assets/style/mainColors.dart';
import 'package:patikmobile/locale/app_localizations.dart';
import 'package:patikmobile/models/word.dart';
import 'package:patikmobile/pages/box_page.dart';
import 'package:patikmobile/pages/games/match_moving_square_game.dart';
import 'package:patikmobile/pages/games/swipe_card_game.dart';
import 'package:patikmobile/providers/categoriesProvider.dart';
import 'package:patikmobile/widgets/box_widget.dart';
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
    categoriesProvider.init(context);
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
                        title: AutoSizeText(category.categoryAppLngName!),
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
                                      left: 8.0.w, top: 1.h, bottom: 0.h),
                                  child: Text(
                                    '${category.categoryOrderName}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 2.3.h),
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            SizedBox(
                              height: 15.h,
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
                                        horizontalCategory.categoryAppLngName!,
                                        horizontalCategory.categoryWordCount!,
                                        horizontalCategory.totalCount!,
                                        horizontalCategory.orderColor!,
                                        horizontalCategory);
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

  Widget categoryBox(String image, String name, int wordCount, int totalCount,
      int color, WordListInformation horizontalCategory) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SwipeCardGame(
                  selectedCategoryInfo: horizontalCategory,
                )));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 30.w,
          height: 15.h,
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 0.4),
            borderRadius: BorderRadius.all(Radius.circular(20)),
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
                  textAlign: TextAlign.center,
                  name,
                  style: TextStyle(
                    fontSize: 1.h,
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
      ),
    );
  }

  Widget boxArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BoxWidget(
            text: AppLocalizations.of(context).translate("101"),
            color: MainColors.boxColor1,
            value: categoriesProvider.getLernedWordCount.toString(),
            iconUrl: 'lib/assets/img/ilearned.png',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BoxPage(
                        selectedBox: 1,
                      )));
            },
          ),
          BoxWidget(
            text: AppLocalizations.of(context).translate("102"),
            color: MainColors.boxColor2,
            value: categoriesProvider.getRepeatedWordCount.toString(),
            iconUrl: 'lib/assets/img/repeat.png',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BoxPage(
                        selectedBox: 2,
                      )));
            },
          ),
          BoxWidget(
            text: AppLocalizations.of(context).translate("103"),
            color: MainColors.boxColor3,
            value: categoriesProvider.getWorkHardCount.toString(),
            iconUrl: 'lib/assets/img/sun.png',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BoxPage(
                        selectedBox: 3,
                      )));
            },
          ),
        ],
      ),
    );
  }
}
