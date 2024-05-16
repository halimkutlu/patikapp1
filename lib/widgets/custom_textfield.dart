// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String name;
  final bool isDate;
  final bool? obscureText;
  final bool readOnly;
  final IconData icon;
  final List<TextInputFormatter>? inputFormatters;
  final bool isBorder;
  final bool isIcon;
  final String? hintText;
  final TextCapitalization textCapitalization;
  final String? placeholder;
  final bool disableFormatDate;
  final String? Function(String?)? validator;
  final TextInputType inputType;
  final bool isDropdown;
  final Function(String)? onChanged;
  final int maxLength;
  final VoidCallback? onTap;
  final bool isTime;
  final bool formatDate;
  final String? errorText;
  final bool isSuffix;
  final IconData? suffixIcon;
  final Color? iconColor;
  final VoidCallback? onSuffixTap;
  final bool preventSpecialCharacters;

  const CTextfield(
      {Key? key,
      required this.controller,
      required this.name,
      this.preventSpecialCharacters = false,
      this.placeholder = "",
      this.validator,
      this.inputType = TextInputType.text,
      this.isDropdown = false,
      this.onTap,
      this.isSuffix = false,
      this.onSuffixTap,
      this.suffixIcon,
      this.obscureText = false,
      this.isDate = false,
      this.readOnly = false,
      this.maxLength = 60,
      this.formatDate = true,
      this.isTime = false,
      this.disableFormatDate = false,
      this.onChanged,
      this.isBorder = false,
      this.errorText,
      this.icon = Icons.mail,
      this.isIcon = true,
      this.inputFormatters,
      this.hintText = "",
      this.textCapitalization = TextCapitalization.none,
      this.iconColor})
      : super(key: key);

  @override
  State<CTextfield> createState() => _CTextfieldState();
}

class _CTextfieldState extends State<CTextfield> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.name),
            ),
          ],
        ),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.obscureText ?? true,
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: Colors.white,
            hintStyle: TextStyle(color: Color.fromARGB(255, 144, 144, 144)),
            prefixIcon: Icon(widget.icon),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 2),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: const Color.fromARGB(255, 0, 0, 0), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
