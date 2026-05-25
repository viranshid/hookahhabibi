import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHOrderModel.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_images.dart';

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

  // ──────────────────────────────────────────────────────────────
  // HEADER
  // ──────────────────────────────────────────────────────────────
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
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          children: [
            Image.asset(
              APPImages.icUserCircle,
              width: 22,
              height: 22,
              color: AppColors.colorECC16E,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                order.customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Oswald',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 20 / 16,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _tableLabel {
    final raw = order.tableNumber.trim();
    return 'T - $raw';
  }

  Widget _headerTable() {
    return SizedBox(
      width: 56,
      height: 50,
      child: Center(
        child: Text(
          _tableLabel,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Oswald',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 16 / 16,
            color: Color(0xFFFFFFFF),
          ),
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
        child: Center(
          child: Image.asset(
            APPImages.icEyeLight,
            width: 22,
            height: 22,
          ),
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
          child: Image.asset(
            APPImages.icThreeDotsVertical,
            width: 32,
            height: 32,
            color: AppColors.colorECC16E,
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // KOT BAND
  // ──────────────────────────────────────────────────────────────
  Widget _buildKotBand(HHKotEntry kot) {
    return Container(
      height: 46,
      decoration: const BoxDecoration(
        color: AppColors.color003210,
        border: Border(
          top: BorderSide(color: Color(0x1AFFFFFF), width: 1),
          bottom: BorderSide(color: Color(0x1AFFFFFF), width: 1),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 26,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    'KOT - ${kot.kotNumber}',
                    style: const TextStyle(
                      fontFamily: 'Oswald',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 16 / 14,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 1,
                    height: 14,
                    color: const Color(0x1AFFFFFF),
                  ),
                  const Spacer(),
                  _kotTimeLabel(kot.time),
                ],
              ),
            ),
          ),
          // dashed separator: width 278, 1px, dashes 3,3, #FFFFFF26
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CustomPaint(
              size: const Size(278, 1),
              painter: _DashedLinePainter(
                color: const Color(0x26FFFFFF),
                dashWidth: 3,
                dashSpace: 3,
                strokeWidth: 1,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _itemCountLabel(),
                      style: const TextStyle(
                        fontFamily: 'Oswald',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 16 / 12,
                        letterSpacing: 12 * 0.05,
                        color: AppColors.colorC4C4C4,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 12,
                    margin: const EdgeInsets.only(right: 15),
                    color: const Color(0x1AFFFFFF),
                  ),
                  const Text(
                    'Qty.',
                    style: TextStyle(
                      fontFamily: 'Oswald',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 16 / 12,
                      letterSpacing: 12 * 0.05,
                      color: AppColors.colorC4C4C4,
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

  String _itemCountLabel() {
    int total = 0;
    for (final entry in order.kotEntries) {
      for (final item in entry.items) {
        total += item.qty;
      }
    }
    return 'Item ($total)';
  }

  Widget _kotTimeLabel(String time) {
    // Expected formats: "10:06" or "10:06 MM:SS"
    final parts = time.split(' ');
    final hhmm = parts.isNotEmpty ? parts.first : time;
    final mmss = parts.length > 1 ? parts.sublist(1).join(' ') : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          hhmm,
          style: const TextStyle(
            fontFamily: 'Oswald',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            height: 16 / 14,
            color: Color(0xFFFFFFFF),
          ),
        ),
        if (mmss != null) ...[
          const SizedBox(width: 4),
          Text(
            mmss,
            style: const TextStyle(
              fontFamily: 'Oswald',
              fontWeight: FontWeight.w300,
              fontSize: 12,
              height: 16 / 12,
              color: Color(0xFFF4F5F7),
            ),
          ),
        ],
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  // ITEMS BODY
  // ──────────────────────────────────────────────────────────────
  Widget _buildItemsBody() {
    final items = <Widget>[];
    for (int i = 0; i < order.kotEntries.length; i++) {
      if (i > 0) items.add(_buildSubKotHeader(order.kotEntries[i]));
      for (final item in order.kotEntries[i].items) {
        items.add(_buildItemRow(item));
      }
    }
    return ListView(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 4),
      children: items,
    );
  }

  Widget _buildSubKotHeader(HHKotEntry kot) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'KOT - ${kot.kotNumber}',
            style: const TextStyle(
              fontFamily: 'Oswald',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              height: 16 / 14,
              color: Color(0xFFFFFFFF),
            ),
          ),
          _kotTimeLabel(kot.time),
        ],
      ),
    );
  }

  Widget _buildItemRow(HHOrderItem item) {
    const itemTextStyle = TextStyle(
      fontFamily: 'Oswald',
      fontWeight: FontWeight.w400,
      fontSize: 15,
      height: 14 / 15,
      color: Color(0xFFFFFFFF),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 170),
            child: Text(
              item.name,
              style: itemTextStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          Text('${item.qty}', style: itemTextStyle),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // FOOTER
  // ──────────────────────────────────────────────────────────────
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _footerIcon(APPImages.icKotCardAdd, disabled ? null : onAddItem),
            const SizedBox(width: 9),
            _footerIcon(APPImages.icKotCardEdit, disabled ? null : onEditNote),
            const SizedBox(width: 9),
            _footerIcon(APPImages.icKotCardNotes, disabled ? null : onViewBill),
            const SizedBox(width: 9),
            _footerIcon(APPImages.icKotCardSplit, disabled ? null : onTransfer),
            const SizedBox(width: 10),
            _settleButton(disabled ? null : onSettle),
          ],
        ),
      ),
    );
  }

  Widget _footerIcon(String assetPath, VoidCallback? onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Image.asset(assetPath, width: 36, height: 36),
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
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Text(
          'Settle Order',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            height: 1.0,
            color: AppColors.colorECC16E,
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    double startX = 0;
    final y = size.height / 2;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) =>
      old.color != color ||
      old.dashWidth != dashWidth ||
      old.dashSpace != dashSpace ||
      old.strokeWidth != strokeWidth;
}
