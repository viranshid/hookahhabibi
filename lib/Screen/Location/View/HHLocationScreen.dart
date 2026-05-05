import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHAppManager.dart';
import 'package:hookahhabibi/Screen/Location/Model/HHLocationCardModel.dart';
import 'package:hookahhabibi/Enums/HHButtonType.dart';
import 'package:hookahhabibi/Enums/HHUserTypeEnum.dart';
import 'package:hookahhabibi/Screen/Location/View/HHLocationCard.dart';
import 'package:hookahhabibi/Screen/Location/View/HHUserTypeCard.dart';
import 'package:hookahhabibi/Screen/Welcom/View/HHWelcom.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';
import 'package:hookahhabibi/utils/app_routes.dart';
import 'package:hookahhabibi/utils/app_Strings.dart';
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
  HHUserType? _selectedUserType;
  bool _isLoading = true;
  String? _errorMessage;
  int _loadAttempts = 0;
  int? _selectedLocationIndex; // Track selected index to avoid unnecessary rebuilds

  @override
  void initState() {
    super.initState();
    print('\n🏠 LOCATION SCREEN: Initialized');
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    print('\n🏠 LOCATION SCREEN: Loading locations');
    print('   Load Attempts: $_loadAttempts');

    if (!mounted) {
      print('   ⚠️  Widget not mounted, cancelling load');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _loadAttempts++;

    // Check if locations are already loaded
    if (_appManager.locationManager.locations.isEmpty) {
      print('   📡 No locations in manager, loading from API...');
      final success = await _appManager.locationManager.loadLocations();

      if (!success) {
        print('   ❌ Failed to load locations from API');

        if (!mounted) return;

        setState(() {
          _errorMessage = _appManager.locationManager.error ?? 'Failed to load locations';
          _isLoading = false;
        });

        // Show error dialog
        _showErrorDialog();
        return;
      }

      print('   ✅ Locations loaded successfully from API');
    } else {
      print('   ✅ Using cached locations (${_appManager.locationManager.locations.length} locations)');
    }

    if (!mounted) return;

    final apiLocations = _appManager.locationManager.locations;

    print('   🔄 Converting ${apiLocations.length} API locations to display format');

    _displayLocations = apiLocations.map((location) {
      return HHLocationCardModel(
        id: location.id,
        title: location.title,
        subtitle: location.address,
        imageUrl: location.image,
        isSelected: false,
      );
    }).toList();

    print('   ✅ Converted ${_displayLocations.length} locations');

    // Auto-select first location
    if (_displayLocations.isNotEmpty) {
      _selectedLocationIndex = 0;
      _selectedLocationId = _displayLocations[0].id;
      print('   ✅ Auto-selected first location: ${_displayLocations[0].title}');
    } else {
      print('   ⚠️  No locations to display!');
      _errorMessage = 'No locations available';
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    print('   ✅ Location screen ready');
  }

  void _showErrorDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF171717),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.margin10),
        ),
        title: const Text(
          'Error Loading Locations',
          style: TextStyle(
            color: AppColors.colorFFFFFF,
            fontFamily: 'Oswald',
            fontSize: 24,
          ),
        ),
        content: Text(
          _errorMessage ?? 'Failed to load locations. Please check your connection and try again.',
          style: const TextStyle(
            color: AppColors.color949494,
            fontFamily: 'Rubik',
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_loadAttempts < 3) {
                _loadLocations();
              } else {
                Navigator.pop(context); // Go back to previous screen
              }
            },
            child: Text(
              _loadAttempts < 3 ? 'Retry' : 'Go Back',
              style: const TextStyle(color: AppColors.colorECC16E),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBlack,
      body: _isLoading
          ? _buildLoadingScreen()
          : _displayLocations.isEmpty
          ? _buildEmptyState()
          : Row(
        children: [
          _buildLeftSide(),
          _buildRightSide(),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
          ),
          const SizedBox(height: Dimens.margin20),
          AppText(
            text: 'Loading locations...',
            appTextStyle: AppTextStyle.jostMedium16Gray,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_off,
            size: 64,
            color: AppColors.color949494,
          ),
          const SizedBox(height: Dimens.margin20),
          AppText(
            text: 'No locations available',
            appTextStyle: AppTextStyle.jostBold26Heading,
          ),
          const SizedBox(height: Dimens.margin10),
          AppText(
            text: _errorMessage ?? 'Please try again later',
            appTextStyle: AppTextStyle.jostMedium16Gray,
          ),
          const SizedBox(height: Dimens.margin30),
          SizedBox(
            width: Dimens.margin200,
            child: HHButton(
              text: 'Retry',
              type: HHButtonType.normal,
              onPressed: () {
                _loadAttempts = 0;
                _loadLocations();
              },
            ),
          ),
        ],
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
            text: APPStrings.locationScreenTitle,
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
            _buildUserTypeSection(),
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
        text: APPStrings.selectRestaurantLocation,
        appTextStyle: AppTextStyle.jostBold36Heading,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLocationsList() {
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
            // Determine if this location is selected based on index
            final isSelected = _selectedLocationIndex == index;
            final locationModel = _displayLocations[index].copyWith(isSelected: isSelected);

            return HHLocationCard(
              location: locationModel,
              onSelectionChanged: (location, _) {
                print('\n📍 Location selection changed: ${location.title}');
                print('   Index: $index');

                // Only update if selection actually changed to avoid unnecessary rebuilds
                if (_selectedLocationIndex != index) {
                  setState(() {
                    _selectedLocationIndex = index;
                    _selectedLocationId = location.id;
                    print('   ✅ Selected Location ID: $_selectedLocationId');
                  });
                }
              },
              onTap: (location) {
                print('   👆 Location tapped: ${location.title} (${location.id})');
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserTypeSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: Dimens.margin30,
            bottom: Dimens.margin20,
          ),
          child: Text(
            APPStrings.selectUserType,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Jost',
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: AppColors.color00541A,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: HHUserTypeCard(
                userType: HHUserType.staff,
                label: APPStrings.staffMember,
                assetIcon: APPImages.icStaffMember,
                isSelected: _selectedUserType == HHUserType.staff,
                onTap: () {
                  print('\n👨‍💼 Staff Member selected');
                  setState(() {
                    _selectedUserType = HHUserType.staff;
                  });
                },
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: HHUserTypeCard(
                userType: HHUserType.customer,
                label: APPStrings.customer,
                assetIcon: APPImages.icCustomer,
                isSelected: _selectedUserType == HHUserType.customer,
                onTap: () {
                  print('\n🧑 Customer selected');
                  setState(() {
                    _selectedUserType = HHUserType.customer;
                  });
                },
              ),
            ),
          ],
        ),
      ],
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
    print('\n➡️  Continue button pressed');

    if (_selectedLocationId == null) {
      print('   ⚠️  No location selected');
      _showSnackBar(APPStrings.selectLocation);
      return;
    }

    if (_selectedUserType == null) {
      print('   ⚠️  No user type selected');
      _showSnackBar(APPStrings.selectUserTypeError);
      return;
    }

    print('   ✅ Selected Location ID: $_selectedLocationId');
    print('   ✅ Selected User Type: ${_selectedUserType!.value}');

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
    print('   🔄 Selecting location in app manager...');
    final locationSuccess = await _appManager.selectLocation(_selectedLocationId!);

    if (!locationSuccess) {
      if (mounted) {
        Navigator.pop(context);
      }
      print('   ❌ Failed to select location in app manager');
      print('   Error: ${_appManager.error}');
      _showSnackBar(_appManager.error ?? 'Failed to select location');
      return;
    }

    // Select user type in app manager
    print('   🔄 Selecting user type in app manager...');
    await _appManager.selectUserType(_selectedUserType!.value);
    print('   ✅ User type selected successfully');

    // Hide loading
    if (mounted) {
      Navigator.pop(context);
    }

    // Get selected location details
    final selectedLocation = (_selectedLocationIndex != null && _selectedLocationIndex! < _displayLocations.length)
        ? _displayLocations[_selectedLocationIndex!]
        : _displayLocations.first;

    print('   🎉 Navigating based on user type');
    print('   Location: ${selectedLocation.title}');
    print('   Location ID: ${selectedLocation.id}');

    if (mounted) {
      if (_selectedUserType == HHUserType.customer) {
        print('   ➡️  Routing to Welcome Screen (Customer flow)');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HHWelcome(
              locationName: selectedLocation.title,
              locationId: selectedLocation.id,
            ),
          ),
        );
      } else {
        print('   ➡️  Routing to Product List Screen (Staff flow)');
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.routesStaffMenu,
        );
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    print('   💬 Showing snackbar: $message');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.colorBD7D28,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}