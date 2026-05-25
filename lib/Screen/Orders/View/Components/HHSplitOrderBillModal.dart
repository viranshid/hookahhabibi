import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hookahhabibi/API/ApiConstants.dart';
import 'package:hookahhabibi/Managers/HHOrderManager.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHBillSplitRequest.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHKotItemModel.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_images.dart';
import 'package:provider/provider.dart';

/// Two-tab modal that lets staff split an existing order's bill either by
/// percentage of total or by assigning individual KOT items to "parts".
///
/// Returns `true` via [Navigator.pop] after a successful split-bill API
/// call, or `null` on Cancel / close / barrier dismiss.
class HHSplitOrderBillModal extends StatefulWidget {
  const HHSplitOrderBillModal({
    Key? key,
    required this.orderId,
    required this.items,
  }) : super(key: key);

  /// The persisted order whose bill is being split.
  final int orderId;

  /// The order's KOT items. Required for item-wise tab; if empty, the
  /// item-wise tab is disabled and only percentage splits can be saved.
  final List<HHKotItemModel> items;

  static Future<bool?> show(
    BuildContext context, {
    required int orderId,
    required List<HHKotItemModel> items,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x99000000),
      builder: (_) => HHSplitOrderBillModal(
        orderId: orderId,
        items: items,
      ),
    );
  }

  @override
  State<HHSplitOrderBillModal> createState() => _HHSplitOrderBillModalState();
}

enum _SplitTab { percentage, itemWise }

class _HHSplitOrderBillModalState extends State<HHSplitOrderBillModal> {
  static const double _modalWidth = 760;
  static const double _modalHeight = 466;

  _SplitTab _selectedTab = _SplitTab.percentage;

  // Percentage state — controllers ONLY for the editable parts (index >= 1).
  // The first part is implicit: it always owns `100 - sum(others)` and is
  // not user-editable.
  final List<TextEditingController> _percentageControllers = [];

  // Percentage name controllers — size == _percentageControllers.length + 1.
  // Index 0 is the auto first card; indexes 1..n match the editable cards.
  final List<TextEditingController> _percentageNameControllers = [];

  // Item-wise state.
  // Items currently in the "All Items" pool (not yet assigned).
  late List<HHKotItemModel> _poolItems;
  // Items the user has checked in the pool but not yet pushed to a part.
  final Set<int> _checkedPoolItemIds = {};
  // Parts the user has created, each holding the assigned items.
  final List<List<HHKotItemModel>> _parts = [[]];
  // Part name controllers — parallel to _parts.
  final List<TextEditingController> _partNameControllers = [];

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _poolItems = List<HHKotItemModel>.from(widget.items);
    _percentageNameControllers.add(TextEditingController(text: _defaultName(1)));
    _partNameControllers.add(TextEditingController(text: _defaultName(1)));
  }

  @override
  void dispose() {
    for (final c in _percentageControllers) {
      c.dispose();
    }
    for (final c in _percentageNameControllers) {
      c.dispose();
    }
    for (final c in _partNameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  static String _defaultName(int oneBasedIndex) =>
      'Part ${oneBasedIndex.toString().padLeft(2, '0')}';

  bool get _itemTabEnabled => widget.items.isNotEmpty;

  // ───────────────────────── build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: SizedBox(
          width: _modalWidth,
          height: _modalHeight,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.color004216,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 30),
                  blurRadius: 15,
                  spreadRadius: -10,
                  color: Color(0x1F000000),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const Divider(
                    height: 1, thickness: 1, color: AppColors.colorWhite33),
                _buildTabBar(),
                Expanded(child: _buildBody()),
                if (_errorMessage != null) _buildErrorStrip(),
                const Divider(
                    height: 1, thickness: 1, color: AppColors.colorWhite33),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── header ─────────────────────────

  Widget _buildHeader() {
    return SizedBox(
      height: 39,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            AppText(
              text: 'Split Order Bill',
              appTextStyle: AppTextStyle.oswaldMedium20White,
              applyTextTransform: false,
            ),
            const Spacer(),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: _isSubmitting ? null : _close,
              child: Image.asset(
                APPImages.icNoteCloseBtn,
                width: 24,
                height: 24,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.cancel,
                  size: 24,
                  color: AppColors.colorFF5F57,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── tabs ─────────────────────────

  Widget _buildTabBar() {
    return Container(
      height: 60.795,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.color00541A, width: 1),
      ),
      child: Row(
        children: [
          _buildTabCell(
            tab: _SplitTab.percentage,
            label: 'Percentage Wise',
            iconAsset: APPImages.icSvgPercentage,
            width: 117,
          ),
          _buildTabCell(
            tab: _SplitTab.itemWise,
            label: 'Item Wise',
            iconAsset: APPImages.icSvgList,
            width: 112,
            enabled: _itemTabEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildTabCell({
    required _SplitTab tab,
    required String label,
    required String iconAsset,
    required double width,
    bool enabled = true,
  }) {
    final isSelected = _selectedTab == tab;
    final color = isSelected
        ? AppColors.colorECC16E
        : (enabled ? AppColors.colorFFFFFF : AppColors.colorWhite33);
    return SizedBox(
      width: width,
      child: Material(
        color: isSelected ? AppColors.color004216 : Colors.transparent,
        child: InkWell(
          onTap: enabled
              ? () => setState(() {
                    _selectedTab = tab;
                    _errorMessage = null;
                  })
              : null,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColors.color00541A, width: 1),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Oswald',
                    fontWeight: isSelected ? FontWeight.w400 : FontWeight.w300,
                    fontSize: 16,
                    height: 1.0,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── body ─────────────────────────

  Widget _buildBody() {
    switch (_selectedTab) {
      case _SplitTab.percentage:
        return _buildPercentageBody();
      case _SplitTab.itemWise:
        return _buildItemWiseBody();
    }
  }

  // ── Percentage tab ──

  Widget _buildPercentageBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Please provide only number',
            style: const TextStyle(
              fontFamily: 'Oswald',
              fontWeight: FontWeight.w500,
              fontSize: 18,
              height: 1.0,
              color: AppColors.colorFFFFFF,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First (auto) card — value = 100 − sum(others), read-only.
                  _buildPercentageCard(
                    index: 0,
                    nameController: _percentageNameControllers[0],
                    valueText: _autoFirstPercentage().toStringAsFixed(
                      _autoFirstPercentage() % 1 == 0 ? 0 : 2,
                    ),
                    editable: false,
                  ),
                  for (var i = 0; i < _percentageControllers.length; i++) ...[
                    const SizedBox(width: 8),
                    _buildPercentageCard(
                      index: i + 1,
                      nameController: _percentageNameControllers[i + 1],
                      controller: _percentageControllers[i],
                      editable: true,
                      onRemove: () => setState(() {
                        _percentageControllers.removeAt(i).dispose();
                        _percentageNameControllers.removeAt(i + 1).dispose();
                      }),
                    ),
                  ],
                  const SizedBox(width: 8),
                  _buildAddMoreButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sum of the values currently entered in the editable cards. Empty /
  /// unparsable entries contribute 0 so the first card stays valid as the
  /// user types.
  num _sumEditedPercentages() {
    num total = 0;
    for (final c in _percentageControllers) {
      final v = num.tryParse(c.text.trim());
      if (v != null) total += v;
    }
    return total;
  }

  num _autoFirstPercentage() {
    final remaining = 100 - _sumEditedPercentages();
    return remaining < 0 ? 0 : remaining;
  }

  Widget _buildPercentageCard({
    required int index,
    required TextEditingController nameController,
    TextEditingController? controller,
    String? valueText,
    required bool editable,
    VoidCallback? onRemove,
  }) {
    return SizedBox(
      width: 180,
      height: 80,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.color004216,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: AppColors.color266528, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: _EditableNameLabel(
                    controller: nameController,
                    fallbackName: _defaultName(index + 1),
                    style: const TextStyle(
                      fontFamily: 'Oswald',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 1.0,
                      color: AppColors.colorF4F7F4,
                    ),
                  ),
                ),
                if (onRemove != null)
                  InkWell(
                    onTap: onRemove,
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: AppColors.colorFF5F57,
                    ),
                  ),
              ],
            ),
            Container(
              height: 32,
              decoration: BoxDecoration(
                color: editable
                    ? AppColors.color17171780
                    : AppColors.color01110A33,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.color01110A33, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: editable
                  ? TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onChanged: (_) => setState(() {}),
                      cursorColor: AppColors.colorFFFFFF,
                      style: const TextStyle(
                        fontFamily: 'Oswald',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.colorFFFFFF,
                      ),
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Enter %',
                        hintStyle: TextStyle(
                          fontFamily: 'Oswald',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: AppColors.colorWhite40,
                        ),
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${valueText ?? '0'} %',
                        style: const TextStyle(
                          fontFamily: 'Oswald',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.colorECC16E,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: SizedBox(
        width: 100,
        height: 36,
        child: Material(
          color: AppColors.color266528,
          borderRadius: BorderRadius.circular(60),
          child: InkWell(
            borderRadius: BorderRadius.circular(60),
            onTap: () {
              setState(() {
                _percentageControllers.add(TextEditingController());
                _percentageNameControllers.add(
                  TextEditingController(
                    text: _defaultName(_percentageNameControllers.length + 1),
                  ),
                );
              });
            },
            child: const Center(
              child: Text(
                'Add More',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1.0,
                  color: AppColors.colorFFFFFF,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Item-wise tab ──

  Widget _buildItemWiseBody() {
    if (!_itemTabEnabled) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No KOT items available for item-wise split.',
            style: TextStyle(
              fontFamily: 'Oswald',
              fontSize: 16,
              color: AppColors.colorWhite33,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 230, child: _buildAllItemsBox()),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < _parts.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildPartBox(i),
                    ),
                  _buildAddPartButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllItemsBox() {
    return Container(
      height: 226,
      decoration: BoxDecoration(
        color: AppColors.color004216,
        border: Border.all(color: AppColors.color266528, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 32,
            color: AppColors.color266528,
            alignment: Alignment.center,
            child: const Text(
              'All Items',
              style: TextStyle(
                fontFamily: 'Oswald',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.colorFFFFFF,
              ),
            ),
          ),
          Expanded(
            child: _poolItems.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'All items assigned',
                        style: TextStyle(
                          fontFamily: 'Oswald',
                          fontSize: 13,
                          color: AppColors.colorWhite33,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    itemCount: _poolItems.length,
                    itemBuilder: (_, i) => _buildPoolRow(_poolItems[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoolRow(HHKotItemModel item) {
    final isChecked = _checkedPoolItemIds.contains(item.id);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isChecked) {
              _checkedPoolItemIds.remove(item.id);
            } else {
              _checkedPoolItemIds.add(item.id);
            }
          });
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              isChecked
                  ? APPImages.icSvgCheckboxSelected
                  : APPImages.icSvgCheckboxOutline,
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.quantity > 1
                    ? '${item.dishTitle} x${item.quantity}'
                    : item.dishTitle,
                style: const TextStyle(
                  fontFamily: 'Oswald',
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                  height: 16 / 14,
                  color: AppColors.colorFFFFFF,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartBox(int index) {
    final partItems = _parts[index];
    return Container(
      width: 230,
      height: 226,
      decoration: BoxDecoration(
        color: AppColors.color004216,
        border: Border.all(color: AppColors.color266528, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 32,
            color: AppColors.color266528,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Flexible(
                  child: _EditableNameLabel(
                    controller: _partNameControllers[index],
                    fallbackName: _defaultName(index + 1),
                    style: const TextStyle(
                      fontFamily: 'Oswald',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.colorFFFFFF,
                    ),
                  ),
                ),
                const Spacer(),
                _buildAddPill(index),
                const SizedBox(width: 8),
                if (_parts.length > 1)
                  InkWell(
                    onTap: () => _removePart(index),
                    child: Image.asset(
                      APPImages.icNoteCloseBtn,
                      width: 16,
                      height: 16,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.cancel,
                        size: 16,
                        color: AppColors.colorFF5F57,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              itemCount: partItems.length,
              itemBuilder: (_, i) {
                final item = partItems[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.quantity > 1
                              ? '${item.dishTitle} x${item.quantity}'
                              : item.dishTitle,
                          style: const TextStyle(
                            fontFamily: 'Oswald',
                            fontWeight: FontWeight.w300,
                            fontSize: 14,
                            height: 16 / 14,
                            color: AppColors.colorFFFFFF,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _returnToPool(index, item),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: AppColors.colorWhite33,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPill(int partIndex) {
    return SizedBox(
      height: 22,
      child: Material(
        color: AppColors.colorD09843,
        borderRadius: BorderRadius.circular(60),
        child: InkWell(
          borderRadius: BorderRadius.circular(60),
          onTap: _checkedPoolItemIds.isEmpty
              ? null
              : () => _assignCheckedToPart(partIndex),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.colorBB7A24, width: 1),
              borderRadius: BorderRadius.circular(60),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Add',
              style: TextStyle(
                fontFamily: 'Oswald',
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.colorFFFFFF,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddPartButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: SizedBox(
        width: 90,
        height: 36,
        child: Material(
          color: AppColors.color266528,
          borderRadius: BorderRadius.circular(60),
          child: InkWell(
            borderRadius: BorderRadius.circular(60),
            onTap: () => setState(() {
              _parts.add([]);
              _partNameControllers.add(
                TextEditingController(
                  text: _defaultName(_partNameControllers.length + 1),
                ),
              );
            }),
            child: const Center(
              child: Text(
                '+ Part',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppColors.colorFFFFFF,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Item-wise state mutators ──

  void _assignCheckedToPart(int partIndex) {
    setState(() {
      final moving = _poolItems
          .where((it) => _checkedPoolItemIds.contains(it.id))
          .toList();
      _parts[partIndex].addAll(moving);
      _poolItems.removeWhere((it) => _checkedPoolItemIds.contains(it.id));
      _checkedPoolItemIds.clear();
    });
  }

  void _returnToPool(int partIndex, HHKotItemModel item) {
    setState(() {
      _parts[partIndex].remove(item);
      _poolItems.add(item);
    });
  }

  void _removePart(int partIndex) {
    setState(() {
      final returning = _parts.removeAt(partIndex);
      _poolItems.addAll(returning);
      _partNameControllers.removeAt(partIndex).dispose();
    });
  }

  // ───────────────────────── footer ─────────────────────────

  Widget _buildErrorStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      color: const Color(0x33FF5F57),
      child: Text(
        _errorMessage!,
        style: const TextStyle(
          fontFamily: 'Oswald',
          fontWeight: FontWeight.w400,
          fontSize: 13,
          color: AppColors.colorFFFFFF,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _footerPill(
            label: 'Cancel',
            backgroundColor: AppColors.colorBlack33,
            onPressed: _isSubmitting ? null : _close,
          ),
          const SizedBox(width: 10),
          _footerPill(
            label: 'Save',
            backgroundColor: AppColors.colorBD7D28,
            onPressed: _isSubmitting ? null : _onSavePressed,
            loading: _isSubmitting,
          ),
        ],
      ),
    );
  }

  Widget _footerPill({
    required String label,
    required Color backgroundColor,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return SizedBox(
      width: 140,
      height: 46,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(60),
        child: InkWell(
          borderRadius: BorderRadius.circular(60),
          onTap: onPressed,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.colorFFFFFF),
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Oswald',
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      height: 1.0,
                      color: AppColors.colorFFFFFF,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ───────────────────────── actions ─────────────────────────

  void _close() => Navigator.of(context).pop();

  Future<void> _onSavePressed() async {
    final List<HHBillSplitRequest> splits;
    final String splitType;

    if (_selectedTab == _SplitTab.percentage) {
      splitType = ApiConstants.splitTypePercentage;
      // Validate the editable cards first.
      final edited = <num>[];
      for (var i = 0; i < _percentageControllers.length; i++) {
        final raw = _percentageControllers[i].text.trim();
        if (raw.isEmpty) {
          _setError(
              'Percentage for Part ${(i + 2).toString().padLeft(2, '0')} is empty.');
          return;
        }
        final v = num.tryParse(raw);
        if (v == null || v <= 0 || v >= 100) {
          _setError('Each percentage must be a number between 0 and 100.');
          return;
        }
        edited.add(v);
      }
      final editedSum = edited.fold<num>(0, (a, b) => a + b);
      if (editedSum >= 100) {
        _setError(
            'Entered percentages add up to $editedSum%; leave some for Part 01.');
        return;
      }
      // Part 01 takes the remainder. All parts together always = 100.
      final firstAuto = 100 - editedSum;
      splits = [
        HHBillSplitRequest.percentage(
          splitName: _resolveName(_percentageNameControllers[0], 1),
          percentage: firstAuto,
        ),
        for (var i = 0; i < edited.length; i++)
          HHBillSplitRequest.percentage(
            splitName: _resolveName(
              _percentageNameControllers[i + 1],
              i + 2,
            ),
            percentage: edited[i],
          ),
      ];
    } else {
      splitType = ApiConstants.splitTypeItemWise;
      if (_poolItems.isNotEmpty) {
        _setError('Assign every item to a part before saving.');
        return;
      }
      final nonEmptyParts = _parts.where((p) => p.isNotEmpty).toList();
      if (nonEmptyParts.isEmpty) {
        _setError('Add at least one item to a part.');
        return;
      }
      splits = [
        for (var i = 0; i < _parts.length; i++)
          if (_parts[i].isNotEmpty)
            HHBillSplitRequest.itemWise(
              splitName: _resolveName(_partNameControllers[i], i + 1),
              items: [
                for (final it in _parts[i])
                  HHBillSplitItem(
                    kotItemId: it.id,
                    qty: it.quantity,
                    price: it.dishPrice,
                  ),
              ],
            ),
      ];
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final manager = context.read<HHOrderManager>();
    final result = await manager.splitBill(
      orderId: widget.orderId,
      splitType: splitType,
      splits: splits,
    );

    if (!mounted) return;
    if (result != null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isSubmitting = false;
      _errorMessage = manager.error ?? 'Failed to split bill.';
    });
  }

  void _setError(String message) {
    setState(() => _errorMessage = message);
  }

  String _resolveName(TextEditingController c, int oneBasedFallbackIndex) {
    final v = c.text.trim();
    return v.isEmpty ? _defaultName(oneBasedFallbackIndex) : v;
  }
}

/// Inline text label with a pencil edit icon. Tapping the icon toggles a
/// borderless TextField that reuses the same [controller]. The Text view
/// rebuilds whenever the controller changes so committed edits show
/// immediately. Empty input on commit falls back to [fallbackName].
class _EditableNameLabel extends StatefulWidget {
  const _EditableNameLabel({
    required this.controller,
    required this.style,
    required this.fallbackName,
  });

  final TextEditingController controller;
  final TextStyle style;
  final String fallbackName;

  @override
  State<_EditableNameLabel> createState() => _EditableNameLabelState();
}

class _EditableNameLabelState extends State<_EditableNameLabel> {
  bool _editing = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _startEdit() {
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      widget.controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.controller.text.length,
      );
    });
  }

  void _finishEdit() {
    if (widget.controller.text.trim().isEmpty) {
      widget.controller.text = widget.fallbackName;
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: _editing
                  ? SizedBox(
                      height: 18,
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        onSubmitted: (_) => _finishEdit(),
                        onTapOutside: (_) => _finishEdit(),
                        cursorColor: widget.style.color,
                        style: widget.style.copyWith(height: 1.0),
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    )
                  : Text(
                      widget.controller.text.isEmpty
                          ? widget.fallbackName
                          : widget.controller.text,
                      style: widget.style,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: _editing ? _finishEdit : _startEdit,
              child: Icon(
                _editing ? Icons.check : Icons.edit,
                size: 12,
                color: widget.style.color ?? Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
