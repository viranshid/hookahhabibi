import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/Product/View/Components/HHStaffMenuHeader.dart';
import 'package:hookahhabibi/utils/app_colors.dart';

class HHStaffMenuScreen extends StatefulWidget {
  const HHStaffMenuScreen({Key? key}) : super(key: key);

  @override
  State<HHStaffMenuScreen> createState() => _HHStaffMenuScreenState();
}

class _HHStaffMenuScreenState extends State<HHStaffMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBlack,
      body: Column(
        children: [
          HHStaffMenuHeader(),
          Expanded(
            child: Container(
              // Placeholder for staff menu content
            ),
          ),
        ],
      ),
    );
  }
}
