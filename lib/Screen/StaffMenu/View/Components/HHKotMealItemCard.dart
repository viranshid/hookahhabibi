import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';

/// Selected meal row rendered inside the KOT panel list.
///
/// Layout: 300 × 62 card with a left remove-button strip, the meal title,
/// quantity stepper, notes button and a right-aligned price.
class HHKotMealItemCard extends StatelessWidget {
  const HHKotMealItemCard({
    Key? key,
    required this.title,
    required this.quantity,
    required this.unitPrice,
    this.currencyPrefix = 'RP. ',
    this.onRemove,
    this.onIncrement,
    this.onDecrement,
    this.onAddNote,
  }) : super(key: key);

  final String title;
  final int quantity;
  final double unitPrice;
  final String currencyPrefix;
  final VoidCallback? onRemove;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onAddNote;

  static const double _cardWidth = Dimens.margin300;
  static const double _cardHeight = Dimens.margin62;
  static const double _removeStripWidth = Dimens.margin30;
  static const double _removeIconSize = Dimens.margin22;
  static const double _stepperSize = Dimens.margin20;
  static const double _qtyWidth = Dimens.margin36;
  static const double _qtyHeight = Dimens.margin20;
  static const double _notesIconSize = Dimens.margin20;

  static const Color _removeStripColor = Color(0x4DFF5F57);
  static const Color _qtyFillColor = Color(0x14000000);

  @override
  Widget build(BuildContext context) {
    final double totalPrice = unitPrice * quantity;

    return SizedBox(
      width: _cardWidth,
      height: _cardHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: AppColors.color00541A,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRemoveStrip(),
                  Expanded(child: _buildContent(totalPrice)),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: Dimens.margin1,
            child: ColoredBox(color: AppColors.color004216),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveStrip() {
    return SizedBox(
      width: _removeStripWidth,
      child: Material(
        color: _removeStripColor,
        child: InkWell(
          onTap: onRemove,
          child: Center(
            child: Image.asset(
              APPImages.icKotMealRemoveBtn,
              width: _removeIconSize,
              height: _removeIconSize,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.close,
                size: _removeIconSize,
                color: AppColors.colorFFFFFF,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(double totalPrice) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimens.margin10,
        Dimens.margin5,
        Dimens.margin10,
        Dimens.margin5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: title,
            appTextStyle: AppTextStyle.oswaldRegular16WhiteTight,
            customColor: AppColors.colorFFFFFF,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            applyTextTransform: false,
          ),
          const SizedBox(height: Dimens.margin10),
          _buildControlsRow(totalPrice),
        ],
      ),
    );
  }

  Widget _buildControlsRow(double totalPrice) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _stepperButton(
          asset: APPImages.icStepperPlus,
          onPressed: onIncrement,
          fallbackIcon: Icons.add,
        ),
        const SizedBox(width: Dimens.margin2),
        _quantityLabel(),
        const SizedBox(width: Dimens.margin2),
        _stepperButton(
          asset: APPImages.icStepperMinus,
          onPressed: onDecrement,
          fallbackIcon: Icons.remove,
        ),
        const SizedBox(width: Dimens.margin5),
        _notesButton(),
        const Spacer(),
        _priceLabel(totalPrice),
      ],
    );
  }

  Widget _stepperButton({
    required String asset,
    required VoidCallback? onPressed,
    required IconData fallbackIcon,
  }) {
    return SizedBox(
      width: _stepperSize,
      height: _stepperSize,
      child: Material(
        color: AppColors.color004216,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Image.asset(
              asset,
              width: _stepperSize,
              height: _stepperSize,
              errorBuilder: (_, __, ___) => Icon(
                fallbackIcon,
                size: Dimens.margin14,
                color: AppColors.colorFFFFFF,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quantityLabel() {
    return Container(
      width: _qtyWidth,
      height: _qtyHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _qtyFillColor,
        borderRadius: BorderRadius.circular(Dimens.margin60),
        border: Border.all(
          color: AppColors.color004216,
          width: Dimens.margin1,
        ),
      ),
      child: Text(
        '$quantity',
        textAlign: TextAlign.center,
        maxLines: 1,
        textHeightBehavior: const TextHeightBehavior(
          applyHeightToFirstAscent: false,
          applyHeightToLastDescent: false,
        ),
        style: const TextStyle(
          fontFamily: 'Rubik',
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 1.0,
          letterSpacing: 0,
          color: AppColors.colorC4C4C4,
        ),
      ),
    );
  }

  Widget _notesButton() {
    return SizedBox(
      width: _notesIconSize,
      height: _notesIconSize,
      child: Material(
        color: AppColors.colorTransparent,
        child: InkWell(
          onTap: onAddNote,
          child: Image.asset(
            APPImages.icSingleMealNotes,
            width: _notesIconSize,
            height: _notesIconSize,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.sticky_note_2_outlined,
              size: _notesIconSize,
              color: AppColors.colorC4C4C4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _priceLabel(double totalPrice) {
    return Text(
      '$currencyPrefix${totalPrice.toStringAsFixed(2)}',
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontFamily: 'Oswald',
        fontWeight: FontWeight.w400,
        fontSize: 18,
        height: 1.0,
        letterSpacing: 0,
        color: AppColors.colorECC16E,
      ),
    );
  }
}
