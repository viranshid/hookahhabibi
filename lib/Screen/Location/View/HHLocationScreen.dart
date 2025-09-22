import 'package:flutter/material.dart';
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
  List<HHLocationCardModel> locations = [
    HHLocationCardModel(
      id: '1',
      title: 'Downtown Hookah Lounge',
      subtitle: 'Experience the finest hookah selection in the heart of the city with premium tobacco blends and comfortable seating for an unforgettable evening.',
      imageUrl: 'http://myapp.hookahhabibi.co.id/uploads/location_images/DkFVgy5x9QRCbisw.png',
      isSelected: false,
    ),
    HHLocationCardModel(
      id: '2',
      title: 'Rooftop Paradise',
      subtitle: 'Enjoy breathtaking city views while savoring our signature hookah flavors in an elegant rooftop setting with ambient lighting and cozy atmosphere.',
      imageUrl: 'http://myapp.hookahhabibi.co.id/uploads/location_images/Zp5A9QkFfp6nN0Rr.png',
      isSelected: true,
    ),
    HHLocationCardModel(
      id: '3',
      title: 'Garden Oasis Lounge',
      subtitle: 'Relax in our beautiful garden atmosphere with natural surroundings and the best hookah experience in town. Perfect for groups and celebrations.',
      imageUrl: 'https://example.com/location3.jpg',
      isSelected: false,
    ),
    HHLocationCardModel(
      id: '4',
      title: 'VIP Elite Lounge',
      subtitle: 'Exclusive premium hookah experience with private seating areas, personalized service, and our finest tobacco collection for discerning customers.',
      imageUrl: 'https://example.com/location4.jpg',
      isSelected: false,
    ),
    HHLocationCardModel(
      id: '5',
      title: 'Beachside Retreat',
      subtitle: 'Oceanfront hookah lounge with stunning beach views, tropical vibes, and refreshing sea breeze. The perfect spot for a relaxing hookah session.',
      imageUrl: 'https://example.com/location5.jpg',
      isSelected: false,
    ),
    HHLocationCardModel(
      id: '6',
      title: 'Traditional Arabian Tent',
      subtitle: 'Authentic middle eastern experience with traditional decor, authentic hookah preparations, and cultural ambiance that transports you to Arabia.',
      imageUrl: 'https://example.com/location6.jpg',
      isSelected: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBlack,
      body: Row(
        children: [
          _buildLeftSide(),
          _buildRightSide(),
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
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: Dimens.margin520,
        ),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: locations.length,
          separatorBuilder: (context, index) => const SizedBox(height: Dimens.margin16),
          itemBuilder: (context, index) {
            return HHLocationCard(
              location: locations[index],
              onSelectionChanged: (location, isSelected) {
                setState(() {
                  // Deselect all other locations
                  for (int i = 0; i < locations.length; i++) {
                    locations[i] = locations[i].copyWith(isSelected: false);
                  }
                  // Select the current location
                  locations[index] = location.copyWith(isSelected: isSelected);
                });
              },
              onTap: (location) {
                print('Location tapped: ${location.title}');
                print('Location ID: ${location.id}');
                print('Location data: ${location.toString()}');
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

  void _handleContinue() {
    // Find selected location
    final selectedLocation = locations.firstWhere(
          (location) => location.isSelected,
      orElse: () => locations.first,
    );

    print('Continue pressed with selected location: ${selectedLocation.title}');

    // Navigate to Welcome Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HHWelcome()),
    );
  }
}