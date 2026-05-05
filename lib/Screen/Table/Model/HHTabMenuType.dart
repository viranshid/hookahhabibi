import 'package:hookahhabibi/utils/app_images.dart';

enum HHTabMenuType {
  table('Table', APPImages.icTableIcon),
  menu('Menu', APPImages.icMenuIcon),
  order('Order', APPImages.icOrderIcon);

  final String label;
  final String iconPath;

  const HHTabMenuType(this.label, this.iconPath);
}
