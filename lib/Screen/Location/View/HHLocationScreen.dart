import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHAppManager.dart';
import 'package:hookahhabibi/Screen/Location/Model/HHLocationCardModel.dart';
import 'package:hookahhabibi/Enums/HHButtonType.dart';
import 'package:hookahhabibi/Screen/Location/View/HHLocationCard.dart';
import 'package:hookahhabibi/Screen/Welcom/View/HHWelcom.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';
import 'package:hookahhabibi/widgets/HHButton.dart';

class HHLocationScreen extends StatefulWidget {
  const HHLocationScreen({Key? key}) : super(key: key);

  @override
  State<HHLocationScreen> createState() => _HHLocationScreenState();
}

class _HHLocationScreenState extends State<HHLocationScreen> {
  final HHAppManager _appManager = HHAppManager();
  List<HHLocationCardModel> _displayLocations = [];
  String? _selectedLocationId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() {
      _isLoading = true;
    });

    // Locations should already be loaded from login
    // But we can reload if needed
    if (_appManager.locationManager.locations.isEmpty) {
      await _appManager.locationManager.loadLocations();
    }

    // Convert API locations to UI models
    final apiLocations = _appManager.locationManager.locations;
    _displayLocations = apiLocations.map((location) {
      return HHLocationCardModel(
        id: location.id,
        title: location.title,
        subtitle: location.address,
        imageUrl: location.image,
        isSelected: false,
      );
    }).toList();

    // Select first location by default
    if (_displayLocations.isNotEmpty) {
      _displayLocations[0] = _displayLocations[0].copyWith(isSelected: true);
      _selectedLocationId = _displayLocations[0].id;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBlack,
      body: _isLoading
          ? _buildLoadingScreen()
          : Row(
        children: [
          _buildLeftSide(),
          _buildRightSide(),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
      ),
    );
  }

  Widget _buildLeftSide() {
    return Expanded(
      flex: 1,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          APPImages.imgLocationSideBar,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildRightSide() {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F7F4),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimens.margin30),
            bottomLeft: Radius.circular(Dimens.margin30),
          ),
        ),
        child: Column(
          children: [
            _buildHeaderBox(),
            _buildContentBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBox() {
    return Container(
      height: Dimens.margin70,
      decoration: const BoxDecoration(
        color: AppColors.colorFFFFFF,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimens.margin30),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: Dimens.margin26),
          child: AppText(
            text: 'Set Location',
            appTextStyle: AppTextStyle.jostBold26Heading,
          ),
        ),
      ),
    );
  }

  Widget _buildContentBox() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.margin60),
        child: Column(
          children: [
            _buildContentTitle(),
            _buildLocationsList(),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildContentTitle() {
    return Padding(
      padding: const EdgeInsets.only(
        top: Dimens.margin40,
        bottom: Dimens.margin30,
      ),
      child: AppText(
        text: 'Select Restaurant Location',
        appTextStyle: AppTextStyle.jostBold36Heading,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLocationsList() {
    if (_displayLocations.isEmpty) {
      return Expanded(
        child: Center(
          child: AppText(
            text: 'No locations available',
            appTextStyle: AppTextStyle.jostMedium16Gray,
          ),
        ),
      );
    }

    return Expanded(
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: Dimens.margin520,
        ),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: _displayLocations.length,
          separatorBuilder: (context, index) => const SizedBox(height: Dimens.margin16),
          itemBuilder: (context, index) {
            return HHLocationCard(
              location: _displayLocations[index],
              onSelectionChanged: (location, isSelected) {
                setState(() {
                  // Deselect all other locations
                  for (int i = 0; i < _displayLocations.length; i++) {
                    _displayLocations[i] = _displayLocations[i].copyWith(isSelected: false);
                  }
                  // Select the current location
                  _displayLocations[index] = location.copyWith(isSelected: isSelected);
                  _selectedLocationId = location.id;
                });
              },
              onTap: (location) {
                print('Location tapped: ${location.title}');
                print('Location ID: ${location.id}');
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.only(
        top: Dimens.margin30,
        bottom: Dimens.margin40,
      ),
      child: SizedBox(
        width: Dimens.margin380,
        child: HHButton(
          text: 'Continue',
          type: HHButtonType.normal,
          onPressed: _handleContinue,
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_selectedLocationId == null) {
      _showSnackBar('Please select a location');
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
        ),
      ),
    );

    // Select location in app manager
    final success = await _appManager.selectLocation(_selectedLocationId!);

    // Hide loading
    if (mounted) {
      Navigator.pop(context);
    }

    if (success) {
      // Get selected location details
      final selectedLocation = _displayLocations.firstWhere(
            (location) => location.isSelected,
        orElse: () => _displayLocations.first,
      );

      print('Continue pressed with selected location: ${selectedLocation.title}');

      // Navigate to Welcome Screen with selected location data
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HHWelcome(
              locationName: selectedLocation.title,
              locationId: selectedLocation.id,
            ),
          ),
        );
      }
    } else {
      _showSnackBar('Failed to select location');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.colorBD7D28,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}