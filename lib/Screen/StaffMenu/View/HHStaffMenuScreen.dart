import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHLocationManager.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/StaffMenuTab.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Components/HHStaffMenuHeader.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:provider/provider.dart';

class HHStaffMenuScreen extends StatefulWidget {
  const HHStaffMenuScreen({Key? key}) : super(key: key);

  @override
  State<HHStaffMenuScreen> createState() => _HHStaffMenuScreenState();
}

class _HHStaffMenuScreenState extends State<HHStaffMenuScreen> {
  StaffMenuTab _selectedTab = StaffMenuTab.tables;

  void _onTabSelected(StaffMenuTab tab) {
    if (tab == _selectedTab) return;
    setState(() => _selectedTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final locationName = context
            .watch<HHLocationManager>()
            .selectedLocation
            ?.title ??
        '';

    return Scaffold(
      backgroundColor: AppColors.colorBlack,
      body: Column(
        children: [
          HHStaffMenuHeader(
            selectedTab: _selectedTab,
            onTabSelected: _onTabSelected,
            locationName: locationName,
          ),
          Expanded(
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
        ],
      ),
    );
  }

  Widget _buildTabContent(StaffMenuTab tab) {
    switch (tab) {
      case StaffMenuTab.tables:
        return const _TabPlaceholder(title: 'HH_Order Table View');
      case StaffMenuTab.menu:
        return const _TabPlaceholder(title: 'Menu');
      case StaffMenuTab.orders:
        return const _TabPlaceholder(title: 'Orders');
    }
  }
}

class _TabPlaceholder extends StatelessWidget {
  final String title;
  const _TabPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
