import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHOrderModel.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';

class HHOrderKOTCard extends StatelessWidget {
  static const double cardWidth = 298;
  static const double cardHeight = 316;

  final HHOrderModel order;
  final VoidCallback? onAddItem;
  final VoidCallback? onEditNote;
  final VoidCallback? onViewBill;
  final VoidCallback? onTransfer;
  final VoidCallback? onSettle;
  final VoidCallback? onMenuTap;
  final VoidCallback? onViewTap;

  const HHOrderKOTCard({
    Key? key,
    required this.order,
    this.onAddItem,
    this.onEditNote,
    this.onViewBill,
    this.onTransfer,
    this.onSettle,
    this.onMenuTap,
    this.onViewTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: AppColors.color012012,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildKotBand(order.kotEntries.first),
              Expanded(child: _buildItemsBody()),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          Container(color: AppColors.color004216),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: 6, color: order.status.indicatorColor),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(height: 1, color: AppColors.color266528),
          ),
          Row(
            children: [
              _headerCustomer(),
              _verticalDivider(),
              _headerTable(),
              _verticalDivider(),
              _headerView(),
              _verticalDivider(),
              _headerMenu(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 50, color: AppColors.color266528);
  }

  Widget _headerCustomer() {
    return SizedBox(
      width: 147,
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            const Icon(Icons.account_circle_outlined,
                size: 18, color: AppColors.colorECC16E),
            const SizedBox(width: 8),
            Expanded(
              child: AppText(
                text: order.customerName,
                appTextStyle: AppTextStyle.jostSemiBold18White,
                customFontSize: 13,
                customFontWeight: FontWeight.w600,
                applyTextTransform: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerTable() {
    return SizedBox(
      width: 56,
      height: 50,
      child: Center(
        child: AppText(
          text: 'T – ${order.tableNumber}',
          appTextStyle: AppTextStyle.jostSemiBold18White,
          customFontSize: 13,
          customFontWeight: FontWeight.w700,
          applyTextTransform: false,
        ),
      ),
    );
  }

  Widget _headerView() {
    return SizedBox(
      width: 41,
      height: 50,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onViewTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.remove_red_eye_outlined,
                size: 18, color: AppColors.colorECC16E),
            const SizedBox(height: 2),
            AppText(
              text: '${order.viewCount}',
              appTextStyle: AppTextStyle.jostSemiBold18White,
              customFontSize: 8,
              applyTextTransform: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerMenu() {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onMenuTap,
        child: Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0x29000000),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.more_vert,
                size: 18, color: AppColors.colorECC16E),
          ),
        ),
      ),
    );
  }

  Widget _buildKotBand(HHKotEntry kot) {
    return Container(
      height: 46,
      color: AppColors.color003210,
      child: Column(
        children: [
          Container(
            height: 25,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0x26FFFFFF), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: 'Kot. ${kot.kotNumber}',
                  appTextStyle: AppTextStyle.jostSemiBold18White,
                  customFontSize: 12,
                  customFontWeight: FontWeight.w600,
                  applyTextTransform: false,
                ),
                AppText(
                  text: kot.time,
                  appTextStyle: AppTextStyle.jostSemiBold18White,
                  customFontSize: 12,
                  applyTextTransform: false,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 21,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: AppText(
                      text: 'Item',
                      appTextStyle: AppTextStyle.jostSemiBold18White,
                      customColor: AppColors.colorC4C4C4,
                      customFontSize: 10,
                      customFontWeight: FontWeight.w400,
                      applyTextTransform: false,
                    ),
                  ),
                  Container(
                    width: 1,
                    color: const Color(0x1AFFFFFF),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  SizedBox(
                    width: 38,
                    child: AppText(
                      text: 'qty.',
                      appTextStyle: AppTextStyle.jostSemiBold18White,
                      customColor: AppColors.colorC4C4C4,
                      customFontSize: 10,
                      customFontWeight: FontWeight.w400,
                      textAlign: TextAlign.right,
                      applyTextTransform: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsBody() {
    final items = <Widget>[];
    for (int i = 0; i < order.kotEntries.length; i++) {
      if (i > 0) items.add(_buildSubKotHeader(order.kotEntries[i]));
      for (final item in order.kotEntries[i].items) {
        items.add(_buildItemRow(item));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: ListView(
        padding: EdgeInsets.zero,
        children: items,
      ),
    );
  }

  Widget _buildSubKotHeader(HHKotEntry kot) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: 'Kot. ${kot.kotNumber}',
            appTextStyle: AppTextStyle.jostSemiBold18White,
            customFontSize: 12,
            customFontWeight: FontWeight.w600,
            applyTextTransform: false,
          ),
          AppText(
            text: kot.time,
            appTextStyle: AppTextStyle.jostSemiBold18White,
            customFontSize: 12,
            applyTextTransform: false,
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(HHOrderItem item) {
    return SizedBox(
      height: 17,
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text: item.name,
              appTextStyle: AppTextStyle.jostSemiBold18White,
              customFontSize: 11,
              customFontWeight: FontWeight.w400,
              applyTextTransform: false,
            ),
          ),
          AppText(
            text: '${item.qty}',
            appTextStyle: AppTextStyle.jostSemiBold18White,
            customFontSize: 11,
            customFontWeight: FontWeight.w400,
            applyTextTransform: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final bool disabled = order.isTerminal;
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: const BoxDecoration(
          color: AppColors.color012012,
          border: Border(
            top: BorderSide(color: Color(0x1AFFFFFF), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _iconButton(Icons.note_add_outlined, disabled ? null : onAddItem),
            _iconButton(Icons.edit_note, disabled ? null : onEditNote),
            _iconButton(Icons.receipt_long_outlined, disabled ? null : onViewBill),
            _iconButton(Icons.swap_horiz, disabled ? null : onTransfer),
            _settleButton(disabled ? null : onSettle),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.color004216,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.colorECC16E),
      ),
    );
  }

  Widget _settleButton(VoidCallback? onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 95,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.color004216,
          borderRadius: BorderRadius.circular(18),
        ),
        child: AppText(
          text: 'Settled Order',
          appTextStyle: AppTextStyle.jostSemiBold18White,
          customColor: AppColors.colorECC16E,
          customFontSize: 13,
          customFontWeight: FontWeight.w600,
          applyTextTransform: false,
        ),
      ),
    );
  }
}
