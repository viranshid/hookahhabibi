import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHAppManager.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHOfferModel.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';

/// Separate Offers Widget - Loads offers independently and caches them
/// This widget is stateful and loads offers only once when first created.
/// Subsequent rebuilds or category changes will not reload offers.
class HHOffers extends StatefulWidget {
  const HHOffers({Key? key}) : super(key: key);

  @override
  State<HHOffers> createState() => _HHOffersState();
}

class _HHOffersState extends State<HHOffers> {
  final HHAppManager _appManager = HHAppManager();
  bool _isLoading = false;
  bool _hasError = false;
  List<HHOfferModel> _offers = [];

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    // Check if offers are already loaded in the manager
    if (_appManager.menuManager.offers.isNotEmpty) {
      setState(() {
        _offers = _appManager.menuManager.offers;
      });
      print('✅ Using cached offers (${_offers.length} offers)');
      return;
    }

    // Load offers from API
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      print('🎁 Loading offers from API');
      await _appManager.menuManager.loadOffers();

      if (mounted) {
        setState(() {
          _offers = _appManager.menuManager.offers;
          _isLoading = false;
        });
        print('✅ Offers loaded successfully (${_offers.length} offers)');
      }
    } catch (e) {
      print('❌ Error loading offers: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if no offers
    if (!_isLoading && !_hasError && _offers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(),
        SizedBox(height: Dimens.margin10),
        _buildContent(),
      ],
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.only(
        top: Dimens.margin10,
        left: Dimens.margin10,
      ),
      child: AppText(
        text: 'Special Offers',
        appTextStyle: AppTextStyle.oswaldMedium22OffWhite,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_offers.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildOffersCarousel();
  }

  Widget _buildLoadingState() {
    return Container(
      height: Dimens.margin160,
      padding: const EdgeInsets.only(left: Dimens.margin10),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: Dimens.margin160,
      padding: const EdgeInsets.only(left: Dimens.margin10),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.colorFF928A,
              size: 40,
            ),
            SizedBox(height: Dimens.margin10),
            Text(
              'Unable to load offers',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: Dimens.textSize14,
                color: AppColors.color949494,
              ),
            ),
            SizedBox(height: Dimens.margin10),
            TextButton(
              onPressed: _loadOffers,
              child: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: Dimens.textSize14,
                  color: AppColors.colorECC16E,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersCarousel() {
    return SizedBox(
      height: Dimens.margin160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: Dimens.margin10),
        physics: const BouncingScrollPhysics(),
        itemCount: _offers.length,
        separatorBuilder: (_, __) => SizedBox(width: Dimens.margin20),
        itemBuilder: (context, index) => _buildOfferCard(_offers[index]),
      ),
    );
  }

  Widget _buildOfferCard(HHOfferModel offer) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('offer_${offer.id}'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (50 * (_offers.indexOf(offer)))),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        width: Dimens.margin420,
        height: Dimens.margin160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.margin10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimens.margin10),
          child: Stack(
            children: [
              Image.network(
                offer.image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.fill,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.color949494.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.colorECC16E),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.color949494.withOpacity(0.3),
                    child: const Center(
                      child: Icon(
                        Icons.local_offer,
                        color: AppColors.colorECC16E,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              // Optional: Add title overlay if needed
              if (offer.title.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimens.margin15,
                      vertical: Dimens.margin10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      offer.title,
                      style: const TextStyle(
                        fontFamily: 'Oswald',
                        fontWeight: FontWeight.w600,
                        fontSize: Dimens.textSize18,
                        color: AppColors.colorECC16E,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}