import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHTableModel.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHTableType.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_images.dart';

class HHTableCard extends StatelessWidget {
  final HHTableModel table;
  final VoidCallback? onTap;

  const HHTableCard({Key? key, required this.table, this.onTap})
      : super(key: key);

  static const double _size = 100;
  static const double _radius = 10;
  static const double _borderWidth = 2;
  static const double _dashLength = 4;
  static const double _gapLength = 4;
  static const double _selectionIconSize = 22;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _size,
        height: _size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _buildFill(),
            _buildBackgroundImage(),
            _buildDashedBorder(),
            _buildContent(),
            if (table.isSelected) _buildSelectionMark(),
          ],
        ),
      ),
    );
  }

  Widget _buildFill() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: table.type.fillColor,
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    final imagePath = table.type.backgroundImage;
    if (imagePath == null) return const SizedBox.shrink();
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDashedBorder() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _DashedRoundedBorderPainter(
          color: table.type.borderColor,
          strokeWidth: _borderWidth,
          radius: _radius,
          dashLength: _dashLength,
          gapLength: _gapLength,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: table.type.isBooked
            ? _buildBookedContent()
            : _buildBlankContent(),
      ),
    );
  }

  Widget _buildBlankContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBlankTableNumber(),
        const SizedBox(height: 6),
        _buildCapacityLabel(),
      ],
    );
  }

  Widget _buildBookedContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMinutesLabel(),
        const SizedBox(height: 4),
        _buildBookedTableNumber(),
        const SizedBox(height: 4),
        _buildCustomerNameLabel(),
      ],
    );
  }

  Widget _buildMinutesLabel() {
    final mins = table.minutes;
    if (mins == null) return const SizedBox.shrink();
    return AppText(
      text: '$mins Min',
      appTextStyle: AppTextStyle.oswaldRegular14Divider,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBookedTableNumber() {
    return AppText(
      text: table.tableNumber,
      appTextStyle: AppTextStyle.oswaldMedium18Colored,
      customColor: table.type.numberColor,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBlankTableNumber() {
    return AppText(
      text: table.tableNumber,
      appTextStyle: AppTextStyle.oswaldMedium22White,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCapacityLabel() {
    return AppText(
      text: 'Cap: ${table.capacity}',
      appTextStyle: AppTextStyle.oswaldRegular16Placeholder,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCustomerNameLabel() {
    final name = table.customerName;
    if (name == null || name.isEmpty) return const SizedBox.shrink();
    return AppText(
      text: name,
      appTextStyle: AppTextStyle.oswaldRegular16White,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSelectionMark() {
    return Positioned(
      top: -_selectionIconSize / 3,
      right: -_selectionIconSize / 3,
      child: Image.asset(
        APPImages.icRightTableCard,
        width: _selectionIconSize,
        height: _selectionIconSize,
      ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double gapLength;

  _DashedRoundedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final metrics = path.computeMetrics().toList();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        final extract = metric.extractPath(
          distance,
          next < metric.length ? next : metric.length,
        );
        canvas.drawPath(extract, paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter old) {
    return old.color != color ||
        old.strokeWidth != strokeWidth ||
        old.radius != radius ||
        old.dashLength != dashLength ||
        old.gapLength != gapLength;
  }
}

