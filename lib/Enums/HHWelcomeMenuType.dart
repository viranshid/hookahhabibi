import 'package:hookahhabibi/utils/app_images.dart';

/// Enum for welcome screen menu items
enum HHWelcomeMenuType {
  newAddition('New Addition', APPImages.imgNewAddition),
  exploreMenu('Explore Menu', APPImages.imgExploreMenu),
  hotAppetizers('Hot Appetizers', APPImages.imgHotAppetizers),
  starters('Starters', APPImages.imgStarters),
  mainCourse('Main Course', APPImages.imgMainCourse),
  desserts('Desserts', APPImages.imgDesserts),
  drinks('Drinks', APPImages.imgDrinks),
  shisha('Shisha', APPImages.imgShisha),
  tea('Tea', APPImages.imgTea);

  const HHWelcomeMenuType(this.title, this.imagePath);

  final String title;
  final String imagePath;

  /// Get all menu items in order
  static List<HHWelcomeMenuType> getAllItems() {
    return [
      newAddition,
      exploreMenu,
      hotAppetizers,
      starters,
      mainCourse,
      desserts,
      drinks,
      shisha,
      tea,
    ];
  }

  /// Get display title (uppercase for UI)
  String get displayTitle => title.toUpperCase();
}