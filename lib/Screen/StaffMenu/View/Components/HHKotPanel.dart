import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHSelectedMealItem.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Components/HHKotMealItemCard.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class HHKotPanel extends StatelessWidget {
  const HHKotPanel({
    Key? key,
    this.customerName = 'Vishal Patel',
    this.tableLabel = 'T-4, 9',
    this.floorLabel = 'Ground\nFloor',
    this.onCommentPressed,
    this.selectedItems = const [],
    this.onIncrementItem,
    this.onDecrementItem,
    this.onRemoveItem,
    this.onAddNote,
  }) : super(key: key);

  final String customerName;
  final String tableLabel;
  final String floorLabel;
  final VoidCallback? onCommentPressed;
  final List<HHSelectedMealItem> selectedItems;
  final ValueChanged<String>? onIncrementItem;
  final ValueChanged<String>? onDecrementItem;
  final ValueChanged<String>? onRemoveItem;
  final ValueChanged<String>? onAddNote;

  double get _totalPrice =>
      selectedItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  static const double _topbarHeight = Dimens.margin50;
  static const double _iconSize = Dimens.margin22;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimens.margin300,
      color: AppColors.color00541A,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopBar(),
          _buildItemsHeader(),
          Expanded(child: _buildItemsList()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildItemsHeader() {
    const TextStyle headerLabelStyle = TextStyle(
      fontFamily: 'Oswald',
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 20 / 12,
      letterSpacing: 0,
      color: AppColors.colorC4C4C4,
    );

    return Container(
      height: Dimens.margin30,
      color: AppColors.color004216,
      padding: const EdgeInsets.only(
        left: Dimens.margin12,
        right: Dimens.margin10,
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Items',
            style: headerLabelStyle.copyWith(
              decoration: TextDecoration.underline,
              decorationColor: AppColors.colorC4C4C4,
            ),
          ),
          const Text(
            'Prices',
            textAlign: TextAlign.right,
            style: headerLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    if (selectedItems.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        vertical: Dimens.margin0,
      ),
      itemCount: selectedItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: Dimens.margin0),
      itemBuilder: (context, index) {
        final item = selectedItems[index];
        return Center(
          child: HHKotMealItemCard(
            key: ValueKey('kot_meal_${item.id}'),
            title: item.title,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            onIncrement: () => onIncrementItem?.call(item.id),
            onDecrement: () => onDecrementItem?.call(item.id),
            onRemove: () => onRemoveItem?.call(item.id),
            onAddNote: () => onAddNote?.call(item.id),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      height: Dimens.margin146,
      decoration: const BoxDecoration(
        color: AppColors.color004216,
        border: Border(
          top: BorderSide(
            color: AppColors.color00541A,
            width: Dimens.margin1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildTotalRow(),
          const SizedBox(height: Dimens.margin10),
          _buildActionButtonsRow(),
          const SizedBox(height: Dimens.margin10),
          _buildSendToKitchenButton(),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    return SizedBox(
      height: Dimens.margin40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.margin10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: 'Total:',
              appTextStyle: AppTextStyle.oswaldRegular18WhiteH20,
              applyTextTransform: false,
            ),
            AppText(
              text: 'RP. ${_totalPrice.toStringAsFixed(2)}',
              appTextStyle: AppTextStyle.oswaldSemiBold20Gold,
              textAlign: TextAlign.right,
              applyTextTransform: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsRow() {
    return SizedBox(
      height: Dimens.margin36,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.margin10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _actionButton(
              label: 'Save',
              width: Dimens.margin75,
              backgroundColor: AppColors.color84994F99,
              onPressed: () {},
            ),
            _actionButton(
              label: 'KOT & Print',
              width: Dimens.margin110,
              backgroundColor: AppColors.color84994F99,
              onPressed: () {},
            ),
            _actionButton(
              label: 'Split',
              width: Dimens.margin75,
              backgroundColor: AppColors.color19552D,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required double width,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: width,
      height: Dimens.margin36,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Dimens.margin60),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimens.margin60),
          onTap: onPressed,
          child: Center(
            child: AppText(
              text: label,
              appTextStyle: AppTextStyle.oswaldMedium18White,
              maxLines: 1,
              applyTextTransform: false,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendToKitchenButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.margin10),
      child: SizedBox(
        width: Dimens.margin280,
        height: Dimens.margin40,
        child: Material(
          color: AppColors.colorBD7D28,
          borderRadius: BorderRadius.circular(Dimens.margin60),
          child: InkWell(
            borderRadius: BorderRadius.circular(Dimens.margin60),
            onTap: () {},
            child: Center(
              child: AppText(
                text: 'Send to the Kitchen',
                appTextStyle: AppTextStyle.oswaldMedium20White,
                maxLines: 1,
                applyTextTransform: false,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: _topbarHeight,
      decoration: BoxDecoration(
        color: AppColors.color004216,
        border: Border.all(
          color: AppColors.color266528,
          width: Dimens.margin1,
        ),
      ),
      child: Row(
        children: [
          _buildCustomerName(),
          _buildSeparator(),
          _buildTableDetails(),
          _buildSeparator(),
          _buildCommentButton(),
          _buildSeparator(),
          _buildFloorDetails(),
        ],
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(
      width: Dimens.margin1,
      color: AppColors.color266528,
    );
  }

  Widget _iconImage(String path) {
    return Image.asset(
      path,
      width: _iconSize,
      height: _iconSize,
      errorBuilder: (_, __, ___) =>
          const SizedBox(width: _iconSize, height: _iconSize),
    );
  }

  Widget _buildCustomerName() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: Dimens.margin10),
        child: Row(
          children: [
            _iconImage(APPImages.icMenuTabPerson),
            const SizedBox(width: Dimens.margin5),
            Expanded(
              child: AppText(
                text: customerName,
                appTextStyle: AppTextStyle.oswaldMedium16White,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                applyTextTransform: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableDetails() {
    return SizedBox(
      width: Dimens.margin50,
      height: _topbarHeight,
      child: Column(
        children: [
          const SizedBox(height: Dimens.margin7),
          _iconImage(APPImages.icMenuTabTable),
          const SizedBox(height: Dimens.margin2),
          SizedBox(
            width: double.infinity,
            child: AppText(
              text: tableLabel,
              appTextStyle: AppTextStyle.oswaldMedium12White,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              applyTextTransform: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentButton() {
    return SizedBox(
      width: Dimens.margin50,
      height: _topbarHeight,
      child: Material(
        color: AppColors.colorTransparent,
        child: InkWell(
          onTap: onCommentPressed,
          child: Center(child: _iconImage(APPImages.icMenuTabDocument)),
        ),
      ),
    );
  }

  Widget _buildFloorDetails() {
    return Container(
      width: Dimens.margin62,
      height: _topbarHeight,
      color: AppColors.color266528,
      alignment: Alignment.center,
      child: AppText(
        text: floorLabel,
        appTextStyle: AppTextStyle.oswaldRegular16WhiteTight,
        maxLines: 2,
        textAlign: TextAlign.center,
        applyTextTransform: false,
      ),
    );
  }
}
