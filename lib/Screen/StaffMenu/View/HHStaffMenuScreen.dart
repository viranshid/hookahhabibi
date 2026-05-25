import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHLocationManager.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHStaffBookingSelection.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/StaffMenuTab.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Components/HHStaffMenuHeader.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Tabs/HHMenuTabScreen.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Tabs/HHOrdersTabScreen.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Tabs/HHTablesTabScreen.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:provider/provider.dart';

class HHStaffMenuScreen extends StatefulWidget {
  const HHStaffMenuScreen({Key? key}) : super(key: key);

  @override
  State<HHStaffMenuScreen> createState() => _HHStaffMenuScreenState();
}

class _HHStaffMenuScreenState extends State<HHStaffMenuScreen> {
  static const double _headerHeight = 80;
  StaffMenuTab _selectedTab = StaffMenuTab.tables;
  HHStaffBookingSelection _booking = HHStaffBookingSelection.empty;

  void _onTabSelected(StaffMenuTab tab) {
    if (tab == _selectedTab) return;
    setState(() => _selectedTab = tab);
  }

  void _onBookingContinue(HHStaffBookingSelection booking) {
    setState(() => _booking = booking);
  }

  @override
  Widget build(BuildContext context) {
    final locationName = context
            .watch<HHLocationManager>()
            .selectedLocation
            ?.title ??
        '';

    return Scaffold(
      backgroundColor: AppColors.color01110A,
      body: Stack(
        children: [
          Positioned.fill(
            top: _headerHeight,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              child: KeyedSubtree(
                key: ValueKey(_selectedTab),
                child: _buildTabContent(_selectedTab),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: HHStaffMenuHeader(
              selectedTab: _selectedTab,
              onTabSelected: _onTabSelected,
              locationName: locationName,
              height: _headerHeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(StaffMenuTab tab) {
    switch (tab) {
      case StaffMenuTab.tables:
        return HHTablesTabScreen(
          onRequestTab: _onTabSelected,
          onBookingContinue: _onBookingContinue,
        );
      case StaffMenuTab.menu:
        return HHMenuTabScreen(
          booking: _booking,
          onRequestTab: _onTabSelected,
        );
      case StaffMenuTab.orders:
        return const HHOrdersTabScreen();
    }
  }
}
