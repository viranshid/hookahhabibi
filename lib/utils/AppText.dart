import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final double size;
  final TextStyle style;
  final TextAlign? textAlign;
  final String? fontFamily;
  final int? maxLines;
  final TextOverflow overflow;

  const AppText({
    Key? key,
    required this.text,
    required this.size,
    required this.style,
    this.textAlign,
    this.fontFamily,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      style: style.copyWith(
        fontSize: size,
        fontFamily: 'Roboto',
        // fontFamilyFallback: ['Arial', 'LucidaGrande', 'sans-serif'],
      ),
      textAlign: textAlign,
    );
  }
}
