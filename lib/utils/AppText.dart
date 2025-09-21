import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';

class AppText extends StatelessWidget {
  final String text;
  final AppTextStyle appTextStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final Color? customColor;
  final double? customFontSize;
  final FontWeight? customFontWeight;
  final bool applyTextTransform;

  const AppText({
    Key? key,
    required this.text,
    required this.appTextStyle,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.customColor,
    this.customFontSize,
    this.customFontWeight,
    this.applyTextTransform = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Apply text transformation if needed
    String displayText = applyTextTransform
        ? appTextStyle.transformText(text)
        : text;

    // Get the base style
    TextStyle style = appTextStyle.style;

    // Apply custom properties if provided
    if (customColor != null || customFontSize != null || customFontWeight != null) {
      style = AppTextStyleManager.getStyleWith(
        style: appTextStyle,
        color: customColor,
        fontSize: customFontSize,
        fontWeight: customFontWeight,
      );
    }

    return Text(
      displayText,
      maxLines: maxLines,
      overflow: overflow,
      style: style,
      textAlign: textAlign,
    );
  }
}

// Alternative constructor for quick usage with just style
class StyledText extends StatelessWidget {
  final String text;
  final AppTextStyle style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const StyledText(
      this.text, {
        Key? key,
        required this.style,
        this.textAlign,
        this.maxLines,
        this.overflow = TextOverflow.ellipsis,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppText(
      text: text,
      appTextStyle: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}