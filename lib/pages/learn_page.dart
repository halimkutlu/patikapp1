import 'package:flutter/material.dart';
import 'package:patikmobile/providers/categoriesProvider.dart';
import 'package:provider/provider.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  late CategoriesProvider categoriesProvider;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    categoriesProvider =
        Provider.of<CategoriesProvider>(context, listen: false);
    categoriesProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [],
      ),
    );
  }
}
