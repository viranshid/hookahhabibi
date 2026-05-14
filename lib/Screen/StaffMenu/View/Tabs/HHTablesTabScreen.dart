import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hookahhabibi/Enums/HHButtonType.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHTableModel.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHTableType.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Tabs/Components/HHTablesGridView.dart';
import 'package:hookahhabibi/Widgets/HHButton.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_images.dart';
import 'package:hookahhabibi/utils/app_routes.dart';

class HHTablesTabScreen extends StatefulWidget {
  const HHTablesTabScreen({Key? key}) : super(key: key);

  @override
  State<HHTablesTabScreen> createState() => _HHTablesTabScreenState();
}

class _HHTablesTabScreenState extends State<HHTablesTabScreen> {
  // Top bar
  static const double _topBarHeight = 50;
  static const double _titleLeftOffset = 315;
  static const double _topBarRightPadding = 20;
  static const double _indicatorSpacing = 24;
  static const double _dotSize = 20;
  static const double _dotLabelGap = 8;
  static const Color _topBarBorderColor = Color(0x1AECC16E);

  // Bottom bar
  static const double _bottomBarHeight = 80;
  static const double _bottomBarLeftPadding = 15;
  static const double _bottomBarRightPadding = 20;
  static const double _bottomBarColumnGap = 80;
  static const double _bottomBarRowGap = 10;
  static const double _continueButtonWidth = 200;
  static const double _continueButtonHeight = 50;
  static const Color _bottomBarBorderColor = AppColors.color00541A80;

  // Sidebar
  static const double _sidebarWidth = 300;

  // Customer details box
  static const double _detailsBoxWidth = 270;
  static const double _detailsBoxHeight = 230;
  static const double _detailsBoxTop = 23;
  static const double _detailsBoxRadius = 10;
  static const Color _detailsBoxBorderColor = Color(0x1AFFFFFF);
  static const double _detailsTitleHeight = 20;
  static const double _detailsTitleHPadding = 8;
  static const double _detailsTitleTopGap = 36;
  static const double _detailsFieldWidth = 240;
  static const double _detailsFieldHeight = 46;
  static const double _detailsFieldRadius = 60;
  static const double _detailsFieldGap = 20;
  static const Color _detailsFieldBorderColor = AppColors.color2B2B2B;

  // Stepper
  static const double _stepperHeight = 46;
  static const double _stepperButtonSize = 40;
  static const double _stepperIconSize = 26;
  static const double _stepperInputWidth = 100;
  static const double _stepperInputHeight = 46;
  static const double _stepperGap = 10;

  static const String _countryCode = '+91';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  int _guestCount = 1;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onCustomerInputChanged);
    _mobileController.addListener(_onCustomerInputChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onCustomerInputChanged);
    _mobileController.removeListener(_onCustomerInputChanged);
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _onCustomerInputChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.color01110A,
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(child: _buildBody()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ─── Top bar ─────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      height: _topBarHeight,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _topBarBorderColor, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: _titleLeftOffset),
          _buildTopBarTitle(),
          const Spacer(),
          _buildIndicators(),
          const SizedBox(width: _topBarRightPadding),
        ],
      ),
    );
  }

  Widget _buildTopBarTitle() {
    return AppText(
      text: 'Table View',
      appTextStyle: AppTextStyle.oswaldRegular18White,
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIndicator(color: AppColors.colorTableBlankBorder, label: 'Blank Table'),
        const SizedBox(width: _indicatorSpacing),
        _buildIndicator(color: AppColors.colorBD7D28, label: 'KOT Running Table'),
        const SizedBox(width: _indicatorSpacing),
        _buildIndicator(color: AppColors.colorTableRunningBlue, label: 'Running Table'),
        const SizedBox(width: _indicatorSpacing),
        _buildIndicator(color: AppColors.colorTablePrintedGreen, label: 'Printed Table'),
      ],
    );
  }

  Widget _buildIndicator({required Color color, required String label}) {
    return SizedBox(
      height: _dotSize,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIndicatorDot(color),
          const SizedBox(width: _dotLabelGap),
          Center(child: _buildIndicatorLabel(label)),
        ],
      ),
    );
  }

  Widget _buildIndicatorDot(Color color) {
    return Container(
      width: _dotSize,
      height: _dotSize,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildIndicatorLabel(String label) {
    return AppText(
      text: label,
      appTextStyle: AppTextStyle.oswaldRegular16White,
    );
  }

  // ─── Body ────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCustomerSidebar(),
        Expanded(
          child: HHTablesGridView(
            areas: _mockAreas,
            onTableTap: _onTableTap,
          ),
        ),
      ],
    );
  }

  void _onTableTap(HHTableModel table) {
    // Will be wired to manager once API is integrated.
  }

  List<HHTableAreaModel> get _mockAreas => const [
        HHTableAreaModel(
          areaId: 1,
          areaName: 'Ground floor',
          tables: [
            HHTableModel(id: 1, tableNumber: 'T-1', capacity: 4, type: HHTableType.blank, locationId: 1, areaId: 1),
            HHTableModel(id: 2, tableNumber: 'T-2', capacity: 4, type: HHTableType.blank, locationId: 1, areaId: 1),
            HHTableModel(id: 3, tableNumber: 'T-3', capacity: 4, type: HHTableType.blank, locationId: 1, areaId: 1),
            HHTableModel(id: 4, tableNumber: 'T-4', capacity: 6, type: HHTableType.blank, locationId: 1, areaId: 1, isSelected: true),
            HHTableModel(id: 5, tableNumber: 'T-5', capacity: 4, type: HHTableType.kotRunning, minutes: 12, customerName: 'Bhavik', locationId: 1, areaId: 1),
            HHTableModel(id: 6, tableNumber: 'T-6', capacity: 4, type: HHTableType.blank, locationId: 1, areaId: 1),
            HHTableModel(id: 7, tableNumber: 'T-7', capacity: 4, type: HHTableType.kotRunning, minutes: 7, customerName: 'Nishant', locationId: 1, areaId: 1),
            HHTableModel(id: 8, tableNumber: 'T-8', capacity: 6, type: HHTableType.blank, locationId: 1, areaId: 1),
            HHTableModel(id: 9, tableNumber: 'T-9', capacity: 6, type: HHTableType.blank, locationId: 1, areaId: 1, isSelected: true),
            HHTableModel(id: 10, tableNumber: 'T-10', capacity: 8, type: HHTableType.blank, locationId: 1, areaId: 1),
            HHTableModel(id: 11, tableNumber: 'T-11', capacity: 5, type: HHTableType.blank, locationId: 1, areaId: 1),
            HHTableModel(id: 12, tableNumber: 'T-12', capacity: 10, type: HHTableType.blank, locationId: 1, areaId: 1),
          ],
        ),
        HHTableAreaModel(
          areaId: 2,
          areaName: 'Basement',
          tables: [
            HHTableModel(id: 13, tableNumber: 'T-13', capacity: 4, type: HHTableType.blank, locationId: 1, areaId: 2),
            HHTableModel(id: 14, tableNumber: 'T-14', capacity: 4, type: HHTableType.blank, locationId: 1, areaId: 2),
            HHTableModel(id: 15, tableNumber: 'T-15', capacity: 4, type: HHTableType.printed, minutes: 22, customerName: 'Vishal Kha…', locationId: 1, areaId: 2),
            HHTableModel(id: 16, tableNumber: 'T-16', capacity: 6, type: HHTableType.blank, locationId: 1, areaId: 2),
            HHTableModel(id: 17, tableNumber: 'T-17', capacity: 4, type: HHTableType.running, minutes: 18, customerName: 'Vishal Kha…', locationId: 1, areaId: 2),
            HHTableModel(id: 18, tableNumber: 'T-18', capacity: 4, type: HHTableType.blank, locationId: 1, areaId: 2),
          ],
        ),
        HHTableAreaModel(
          areaId: 3,
          areaName: 'Balcony',
          tables: [
            HHTableModel(id: 19, tableNumber: 'T-19', capacity: 4, type: HHTableType.blank, locationId: 1, areaId: 3),
            HHTableModel(id: 20, tableNumber: 'T-20', capacity: 4, type: HHTableType.blank, locationId: 1, areaId: 3),
            HHTableModel(id: 21, tableNumber: 'T-21', capacity: 4, type: HHTableType.blank, locationId: 1, areaId: 3),
            HHTableModel(id: 22, tableNumber: 'T-22', capacity: 4, type: HHTableType.blank, locationId: 1, areaId: 3),
            HHTableModel(id: 23, tableNumber: 'T-23', capacity: 4, type: HHTableType.blank, locationId: 1, areaId: 3),
            HHTableModel(id: 24, tableNumber: 'T-24', capacity: 4, type: HHTableType.blank, locationId: 1, areaId: 3),
            HHTableModel(id: 25, tableNumber: 'T-25', capacity: 4, type: HHTableType.blank, locationId: 1, areaId: 3),
            HHTableModel(id: 26, tableNumber: 'T-26', capacity: 4, type: HHTableType.blank, locationId: 1, areaId: 3),
          ],
        ),
      ];

  Widget _buildCustomerSidebar() {
    return SizedBox(
      width: _sidebarWidth,
      child: _buildSidebarContent(),
    );
  }

  Widget _buildSidebarContent() {
    return Padding(
      padding: const EdgeInsets.only(
        top: _detailsBoxTop,
        left: 15,
        right: 15,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: _buildCustomerDetailsBox(),
      ),
    );
  }

  // ─── Customer details box ────────────────────────────────────────────────
  Widget _buildCustomerDetailsBox() {
    return SizedBox(
      width: _detailsBoxWidth,
      height: _detailsBoxHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          _buildDetailsBoxFrame(),
          _buildDetailsBoxTitle(),
        ],
      ),
    );
  }

  Widget _buildDetailsBoxFrame() {
    return Container(
      width: _detailsBoxWidth,
      height: _detailsBoxHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_detailsBoxRadius),
        border: Border.all(color: _detailsBoxBorderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: _detailsTitleTopGap),
          _buildNameField(),
          const SizedBox(height: _detailsFieldGap),
          _buildMobileField(),
          const SizedBox(height: _detailsFieldGap),
          _buildGuestStepper(),
        ],
      ),
    );
  }

  Widget _buildDetailsBoxTitle() {
    return Positioned(
      top: -_detailsTitleHeight / 2,
      child: Container(
        height: _detailsTitleHeight,
        padding:
            const EdgeInsets.symmetric(horizontal: _detailsTitleHPadding),
        alignment: Alignment.center,
        child: AppText(
          text: 'Customer Details',
          appTextStyle: AppTextStyle.jostMedium19White,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return _buildPillFieldShell(
      child: _buildPlainTextField(
        controller: _nameController,
        hint: 'Customer Name *',
        keyboardType: TextInputType.name,
      ),
    );
  }

  Widget _buildMobileField() {
    return _buildPillFieldShell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCountryCode(),
          const SizedBox(width: 10),
          _buildMobileSeparator(),
          const SizedBox(width: 10),
          Expanded(
            child: _buildPlainTextField(
              controller: _mobileController,
              hint: 'Mobile Number',
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillFieldShell({required Widget child}) {
    return Container(
      width: _detailsFieldWidth,
      height: _detailsFieldHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_detailsFieldRadius),
        border: Border.all(color: _detailsFieldBorderColor, width: 1),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  Widget _buildPlainTextField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: (_) => setState(() {}),
      cursorColor: AppColors.colorECC16E,
      style: AppTextStyleManager.getStyle(AppTextStyle.rubikRegular16Divider)
          .copyWith(color: AppColors.colorFFFFFF),
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: hint,
        hintStyle:
            AppTextStyleManager.getStyle(AppTextStyle.rubikRegular16Placeholder),
      ),
    );
  }

  Widget _buildCountryCode() {
    return AppText(
      text: _countryCode,
      appTextStyle: AppTextStyle.rubikRegular16Divider,
    );
  }

  Widget _buildMobileSeparator() {
    return Container(
      width: 1,
      height: 20,
      color: _detailsFieldBorderColor,
    );
  }

  // ─── Guest stepper ───────────────────────────────────────────────────────
  Widget _buildGuestStepper() {
    return SizedBox(
      height: _stepperHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildStepperButton(
            iconPath: APPImages.icStepperPlus,
            onTap: _incrementGuests,
          ),
          const SizedBox(width: _stepperGap),
          _buildGuestCountField(),
          const SizedBox(width: _stepperGap),
          _buildStepperButton(
            iconPath: APPImages.icStepperMinus,
            onTap: _decrementGuests,
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return InkResponse(
      onTap: onTap,
      radius: _stepperButtonSize,
      child: Container(
        width: _stepperButtonSize,
        height: _stepperButtonSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _detailsFieldBorderColor, width: 1),
        ),
        child: Image.asset(
          iconPath,
          width: _stepperIconSize,
          height: _stepperIconSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildGuestCountField() {
    return Container(
      width: _stepperInputWidth,
      height: _stepperInputHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_detailsFieldRadius),
        border: Border.all(color: _detailsFieldBorderColor, width: 1),
      ),
      child: AppText(
        text: '$_guestCount',
        appTextStyle: AppTextStyle.rubikRegular16Divider,
        textAlign: TextAlign.center,
      ),
    );
  }

  void _incrementGuests() {
    setState(() => _guestCount += 1);
  }

  void _decrementGuests() {
    if (_guestCount <= 1) return;
    setState(() => _guestCount -= 1);
  }

  // ─── Bottom bar ──────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      width: double.infinity,
      height: _bottomBarHeight,
      padding: const EdgeInsets.only(
        left: _bottomBarLeftPadding,
        right: _bottomBarRightPadding,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: _bottomBarBorderColor, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildCustomerDetailsSummary()),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailsSummary() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildDetailsColumn(
          rows: [
            _buildDetailRow(label: 'Customer Name', value: _displayName()),
            const SizedBox(height: _bottomBarRowGap),
            _buildDetailRow(label: 'Customer No.', value: _displayMobile()),
          ],
        ),
        const SizedBox(width: _bottomBarColumnGap),
        _buildDetailsColumn(
          rows: [
            _buildDetailRow(label: 'Guests', value: '$_guestCount'),
            const SizedBox(height: _bottomBarRowGap),
            _buildDetailRow(label: 'Table No.', value: 'T-4, T-9'),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsColumn({required List<Widget> rows}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildDetailLabel(label),
        const SizedBox(width: 6),
        _buildDetailValue(value),
      ],
    );
  }

  Widget _buildDetailLabel(String label) {
    return AppText(
      text: '$label :',
      appTextStyle: AppTextStyle.oswaldRegular18Placeholder,
    );
  }

  Widget _buildDetailValue(String value) {
    return AppText(
      text: value,
      appTextStyle: AppTextStyle.oswaldRegular18White,
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: _continueButtonWidth,
      height: _continueButtonHeight,
      child: HHButton(
        text: 'Continue',
        type: HHButtonType.normal,
        width: _continueButtonWidth,
        height: _continueButtonHeight,
        onPressed: _onContinuePressed,
      ),
    );
  }

  void _onContinuePressed() {
    Navigator.of(context).pushNamed(AppRoutes.routesProductList);
  }

  String _displayName() {
    final text = _nameController.text.trim();
    return text.isEmpty ? '—' : text;
  }

  String _displayMobile() {
    final text = _mobileController.text.trim();
    return text.isEmpty ? '—' : '$_countryCode $text';
  }
}
