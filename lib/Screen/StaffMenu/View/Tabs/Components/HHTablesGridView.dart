import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHTableModel.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Tabs/Components/HHTableCard.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';

class HHTablesGridView extends StatelessWidget {
  final List<HHTableAreaModel> areas;
  final ValueChanged<HHTableModel>? onTableTap;

  const HHTablesGridView({
    Key? key,
    required this.areas,
    this.onTableTap,
  }) : super(key: key);

  static const double _horizontalPadding = 20;
  static const double _topPadding = 20;
  static const double _sectionGap = 24;
  static const double _cardSpacing = 16;
  static const double _cardRunSpacing = 16;
  static const double _separatorTitleGap = 12;
  static const Color _separatorColor = Color(0x26FFFFFF);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: _horizontalPadding,
        right: _horizontalPadding,
        top: _topPadding,
        bottom: _topPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < areas.length; i++) ...[
            if (i > 0) const SizedBox(height: _sectionGap),
            _buildAreaSection(areas[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildAreaSection(HHTableAreaModel area) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAreaSeparator(area.areaName),
        const SizedBox(height: 16),
        _buildAreaTables(area.tables),
      ],
    );
  }

  Widget _buildAreaSeparator(String areaName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(child: _SeparatorLine(color: _separatorColor)),
        const SizedBox(width: _separatorTitleGap),
        _buildAreaName(areaName),
        const SizedBox(width: _separatorTitleGap),
        const Expanded(child: _SeparatorLine(color: _separatorColor)),
      ],
    );
  }

  Widget _buildAreaName(String areaName) {
    return AppText(
      text: areaName,
      appTextStyle: AppTextStyle.oswaldLight20Placeholder,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAreaTables(List<HHTableModel> tables) {
    return Wrap(
      spacing: _cardSpacing,
      runSpacing: _cardRunSpacing,
      children: [
        for (final table in tables)
          HHTableCard(
            table: table,
            onTap: onTableTap == null ? null : () => onTableTap!(table),
          ),
      ],
    );
  }
}

class _SeparatorLine extends StatelessWidget {
  final Color color;
  const _SeparatorLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: color);
  }
}
