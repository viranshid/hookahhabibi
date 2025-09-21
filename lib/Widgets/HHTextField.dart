import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';

class HHTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool isSecureField;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;  // ✅ Added this missing parameter
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Color? fillColor;
  final Color? borderColor;
  final FocusNode? focusNode;

  const HHTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.labelText,
    this.isSecureField = false,
    this.keyboardType,
    this.textInputAction,  // ✅ Added this missing parameter
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.hintStyle,
    this.textStyle,
    this.fillColor,
    this.borderColor,
    this.focusNode,
  }) : super(key: key);

  @override
  State<HHTextField> createState() => _HHTextFieldState();
}

class _HHTextFieldState extends State<HHTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isSecureField;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget? _buildSuffixIcon() {
    if (widget.isSecureField) {
      return Padding(
        padding: const EdgeInsets.only(right: Dimens.margin20),
        child: GestureDetector(
          onTap: _togglePasswordVisibility,
          child: Container(
            width: Dimens.margin21,
            height: Dimens.margin15,
            alignment: Alignment.center,
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              size: Dimens.margin15,
              color: AppColors.color949494,
            ),
          ),
        ),
      );
    }
    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimens.margin56,
      decoration: BoxDecoration(
        color: widget.fillColor ?? AppColors.color171717.withOpacity(0.79), // #171717C9
        borderRadius: BorderRadius.circular(Dimens.margin30), // 60px radius / 2 = 30
        border: Border.all(
          color: widget.borderColor ?? AppColors.color2B2B2B,
          width: Dimens.margin1,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.isSecureField ? _obscureText : false,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction ?? TextInputAction.done,  // ✅ Added this line
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        validator: widget.validator,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        style: widget.textStyle ??
            const TextStyle(
              color: AppColors.colorFFFFFF,
              fontSize: Dimens.textSize16,
              fontFamily: 'Roboto',
            ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          hintStyle: widget.hintStyle ??
              const TextStyle(
                color: AppColors.color949494,
                fontSize: Dimens.textSize16,
                fontFamily: 'Roboto',
              ),
          prefixIcon: widget.prefixIcon,
          suffixIcon: _buildSuffixIcon(),
          suffixIconConstraints: widget.isSecureField
              ? const BoxConstraints(
            minWidth: Dimens.margin41, // 21 + 20 padding
            minHeight: Dimens.margin15,
          )
              : null,
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: Dimens.margin20,
                vertical: Dimens.margin16,
              ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          filled: false,
          counterText: '', // Hide character counter
        ),
      ),
    );
  }
}