import 'package:hookahhabibi/utils/app_images.dart';

enum StaffMenuTab {
  tables(label: 'Tables', icon: APPImages.icTableIcon),
  menu(label: 'Menu', icon: APPImages.icMenuIcon),
  orders(label: 'Orders', icon: APPImages.icOrderIcon);

  final String label;
  final String icon;

  const StaffMenuTab({required this.label, required this.icon});
}
