import 'package:flutter/material.dart';
import 'package:patikmobile/providers/boxPageProvider.dart';
import 'package:provider/provider.dart';

class BoxPage extends StatefulWidget {
  final int selectedBox;
  const BoxPage({super.key, required this.selectedBox});

  @override
  State<BoxPage> createState() => _BoxPageState();
}

class _BoxPageState extends State<BoxPage> {
  late BoxPageProvider categoriesProvider;

  @override
  void initState() {
    super.initState();
    categoriesProvider = Provider.of<BoxPageProvider>(context, listen: false);
    categoriesProvider.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
