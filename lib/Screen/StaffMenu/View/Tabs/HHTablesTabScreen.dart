import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hookahhabibi/Enums/HHButtonType.dart';
import 'package:hookahhabibi/Managers/HHCustomerManager.dart';
import 'package:hookahhabibi/Managers/HHSessionManager.dart';
import 'package:hookahhabibi/Screen/Customer/Model/HHCustomerModel.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHTableModel.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Service/HHTableService.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Tabs/Components/HHTablesGridView.dart';
import 'package:hookahhabibi/Widgets/HHButton.dart';
import 'package:hookahhabibi/Widgets/HHErrorView.dart';
import 'package:hookahhabibi/Widgets/HHLoadingView.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_images.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHStaffBookingSelection.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/StaffMenuTab.dart';
import 'package:provider/provider.dart';

class HHTablesTabScreen extends StatefulWidget {
  /// Optional callback used by the parent [HHStaffMenuScreen] to switch
  /// tabs in place (e.g. after Continue, jump to the Menu tab without
  /// pushing a new route).
  final ValueChanged<StaffMenuTab>? onRequestTab;

  /// Emitted on Continue with a snapshot of the picked customer + tables
  /// + floor so the parent can pass it to the Menu tab.
  final ValueChanged<HHStaffBookingSelection>? onBookingContinue;

  const HHTablesTabScreen({
    Key? key,
    this.onRequestTab,
    this.onBookingContinue,
  }) : super(key: key);

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
  final FocusNode _nameFocus = FocusNode();
  final LayerLink _nameFieldLink = LayerLink();
  final OverlayPortalController _suggestionsCtrl = OverlayPortalController();
  bool _suppressNameSearch = false;
  int _guestCount = 1;

  final HHTableService _tableService = HHTableService();
  List<HHTableAreaModel> _areas = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onCustomerInputChanged);
    _mobileController.addListener(_onCustomerInputChanged);
    _nameFocus.addListener(_onNameFocusChanged);
    _loadTables();
  }

  Future<void> _loadTables() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final session = HHSessionManager();
    final token = session.bearerToken;
    final locationIdRaw = session.selectedLocation?.id;
    final locationId = int.tryParse(locationIdRaw ?? '');

    if (token == null || token.isEmpty || locationId == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Session expired. Please log in and select a location again.';
      });
      return;
    }

    final response = await _tableService.getTables(
      bearerToken: token,
      locationId: locationId,
    );

    if (!mounted) return;

    if (!response.success || response.data == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = response.message ?? 'Failed to load tables.';
      });
      return;
    }

    final areas = <HHTableAreaModel>[];
    for (final location in response.data!) {
      areas.addAll(location.areas);
    }

    setState(() {
      _isLoading = false;
      _areas = areas;
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_onCustomerInputChanged);
    _mobileController.removeListener(_onCustomerInputChanged);
    _nameFocus.removeListener(_onNameFocusChanged);
    _nameController.dispose();
    _mobileController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _onCustomerInputChanged() => setState(() {});

  void _onNameFocusChanged() {
    if (!_nameFocus.hasFocus) {
      // Defer so a tap on a suggestion row can fire before we close.
      Future.delayed(const Duration(milliseconds: 120), () {
        if (!mounted) return;
        if (!_nameFocus.hasFocus && _suggestionsCtrl.isShowing) {
          _suggestionsCtrl.hide();
          context.read<HHCustomerManager>().clearResults();
        }
      });
    } else {
      final manager = context.read<HHCustomerManager>();
      if (manager.searchResults.isNotEmpty || manager.isSearching) {
        _suggestionsCtrl.show();
      }
    }
  }

  void _onNameChanged(String value) {
    setState(() {});
    if (_suppressNameSearch) return;

    final manager = context.read<HHCustomerManager>();
    // Editing after a selection clears the bound customer.
    if (manager.selectedCustomer != null &&
        manager.selectedCustomer!.name != value) {
      manager.clearSelection(keepResults: true);
    }

    manager.searchDebounced(value);

    if (value.trim().isNotEmpty) {
      if (!_suggestionsCtrl.isShowing) _suggestionsCtrl.show();
    } else {
      if (_suggestionsCtrl.isShowing) _suggestionsCtrl.hide();
    }
  }

  void _onCustomerPicked(HHCustomerModel customer) {
    _suppressNameSearch = true;
    _nameController.text = customer.name;
    _nameController.selection =
        TextSelection.collapsed(offset: _nameController.text.length);
    _mobileController.text = customer.phone;
    _suppressNameSearch = false;
    context.read<HHCustomerManager>().selectCustomer(customer);
    _suggestionsCtrl.hide();
    _nameFocus.unfocus();
    setState(() {});
  }

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
        Expanded(child: _buildTablesContent()),
      ],
    );
  }

  Widget _buildTablesContent() {
    if (_isLoading) {
      return const HHLoadingView(message: 'Loading tables...');
    }
    if (_errorMessage != null) {
      return HHErrorView(
        message: _errorMessage!,
        retryLabel: 'Retry',
        onRetry: _loadTables,
      );
    }
    return HHTablesGridView(
      areas: _areas,
      onTableTap: _onTableTap,
    );
  }

  void _onTableTap(HHTableModel table) {
    setState(() {
      _areas = _areas
          .map((area) => HHTableAreaModel(
                areaId: area.areaId,
                areaName: area.areaName,
                tables: area.tables
                    .map((t) => t.id == table.id
                        ? t.copyWith(isSelected: !t.isSelected)
                        : t)
                    .toList(),
              ))
          .toList();
    });
  }

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
    return CompositedTransformTarget(
      link: _nameFieldLink,
      child: OverlayPortal(
        controller: _suggestionsCtrl,
        overlayChildBuilder: _buildSuggestionsOverlay,
        child: _buildPillFieldShell(
          child: _buildPlainTextField(
            controller: _nameController,
            focusNode: _nameFocus,
            hint: 'Customer Name *',
            keyboardType: TextInputType.name,
            onChanged: _onNameChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsOverlay(BuildContext context) {
    final manager = context.watch<HHCustomerManager>();
    return Positioned(
      width: _detailsFieldWidth,
      child: CompositedTransformFollower(
        link: _nameFieldLink,
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        offset: const Offset(0, 6),
        child: Material(
          color: Colors.transparent,
          child: _buildSuggestionsCard(manager),
        ),
      ),
    );
  }

  Widget _buildSuggestionsCard(HHCustomerManager manager) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: AppColors.color2B2B2B,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33ECC16E), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: _buildSuggestionsBody(manager),
    );
  }

  Widget _buildSuggestionsBody(HHCustomerManager manager) {
    if (manager.isSearching && manager.searchResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.colorECC16E),
            ),
          ),
        ),
      );
    }

    if (manager.error != null && manager.searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: AppText(
          text: manager.error!,
          appTextStyle: AppTextStyle.rubikRegular16Placeholder,
        ),
      );
    }

    if (manager.searchResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: AppText(
          text: 'No matching customers',
          appTextStyle: AppTextStyle.rubikRegular16Placeholder,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 6),
      shrinkWrap: true,
      itemCount: manager.searchResults.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        color: Color(0x22FFFFFF),
      ),
      itemBuilder: (_, i) => _buildSuggestionRow(manager.searchResults[i]),
    );
  }

  Widget _buildSuggestionRow(HHCustomerModel c) {
    return InkWell(
      onTap: () => _onCustomerPicked(c),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: c.name,
              appTextStyle: AppTextStyle.jostMedium19White,
            ),
            const SizedBox(height: 2),
            AppText(
              text: c.phone.isEmpty ? '—' : '$_countryCode ${c.phone}',
              appTextStyle: AppTextStyle.rubikRegular16Placeholder,
            ),
          ],
        ),
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
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged ?? (_) => setState(() {}),
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
            _buildDetailRow(label: 'Table No.', value: _selectedTablesLabel()),
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
        isEnabled: _canContinue,
        onPressed: _onContinuePressed,
      ),
    );
  }

  /// Continue is enabled only when the staff has filled the minimum needed
  /// to place an order on the next tab: customer name + phone + at least
  /// one table selected. Re-evaluated automatically — controllers feed
  /// `_onCustomerInputChanged` (which calls setState) and table taps
  /// already setState through `_areas`.
  bool get _canContinue {
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasPhone = _mobileController.text.trim().isNotEmpty;
    final hasTable = _areas.any((a) => a.tables.any((t) => t.isSelected));
    return hasName && hasPhone && hasTable;
  }

  void _onContinuePressed() {
    // Emit the selection to the parent so the Menu tab can render the
    // customer / table / floor in its right-side KOT panel header.
    widget.onBookingContinue?.call(_buildBookingSelection());

    // Switch to the Menu tab inside HHStaffMenuScreen rather than pushing
    // a new route. Falls back to a pushNamed only if the parent didn't
    // wire the callback (shouldn't happen in normal navigation).
    final requestTab = widget.onRequestTab;
    if (requestTab != null) {
      requestTab(StaffMenuTab.menu);
    }
  }

  HHStaffBookingSelection _buildBookingSelection() {
    // Collect server ids for the selected tables.
    final tableIds = <int>[];
    for (final area in _areas) {
      for (final t in area.tables) {
        if (t.isSelected) tableIds.add(t.id);
      }
    }

    final session = HHSessionManager();
    final locationId =
        int.tryParse(session.selectedLocation?.id ?? '');

    final selectedCustomer =
        context.read<HHCustomerManager>().selectedCustomer;

    return HHStaffBookingSelection(
      customerName: _displayName(),
      tableLabel: _selectedTablesLabel(),
      floorLabel: _selectedFloorLabel(),
      customerPhone: _mobileController.text.trim(),
      customerId: selectedCustomer?.id,
      tableIds: tableIds,
      locationId: locationId,
    );
  }

  /// Collects the area names that have at least one selected table.
  /// Single-area → renders on two lines (e.g. "Ground\nFloor"); multi-area
  /// joins with `, `.
  String _selectedFloorLabel() {
    final names = <String>[];
    for (final area in _areas) {
      final hasSelected = area.tables.any((t) => t.isSelected);
      if (hasSelected && area.areaName.isNotEmpty) {
        names.add(area.areaName);
      }
    }
    if (names.isEmpty) return '—';
    if (names.length == 1) {
      // Soft-wrap single area name on the space so it renders on two lines
      // in the narrow floor pill of HHKotPanel (e.g. "Ground Floor" →
      // "Ground\nFloor"). Falls through unchanged if no space.
      final name = names.first;
      final spaceIdx = name.indexOf(' ');
      return spaceIdx > 0
          ? '${name.substring(0, spaceIdx)}\n${name.substring(spaceIdx + 1)}'
          : name;
    }
    return names.join(', ');
  }

  String _selectedTablesLabel() {
    final selected = <String>[];
    for (final area in _areas) {
      for (final t in area.tables) {
        if (t.isSelected) selected.add(t.displayTableNumber);
      }
    }
    return selected.isEmpty ? '—' : selected.join(', ');
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
