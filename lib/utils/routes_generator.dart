import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/Location/View/HHLocationScreen.dart';
import 'package:hookahhabibi/Screen/SplashScreen.dart';
import 'package:hookahhabibi/Screen/Login/HHLogin.dart';
import 'package:hookahhabibi/utils/app_routes.dart';

/// > RouteGenerator is a class that generates routes for the application
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print("Generating route for: ${settings.name}");
    // printWrapped('\x1B[32m${'Navigating to ----> ${settings.name}'}\x1B[0m');
    // ignore: unused_local_variable
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.routesSplash:
        return MaterialPageRoute(
            builder: (_) => const SplashScreen(),
            settings: const RouteSettings(name: AppRoutes.routesSplash));

      case AppRoutes.routesLogin:
        return MaterialPageRoute(
            builder: (_) => const HHLogin(),
            settings: const RouteSettings(name: AppRoutes.routesLogin));

      case AppRoutes.routesLocation: // Add this new route
        return MaterialPageRoute(
            builder: (_) => const HHLocationScreen(),
            settings: const RouteSettings(name: AppRoutes.routesLocation));

      default:
        return MaterialPageRoute(
            builder: (_) => const SplashScreen(),
            settings: const RouteSettings(name: AppRoutes.routesSplash));
    }
  }

  /// If the current route is the home route, return the home route name, otherwise
  /// return the route name of the current route.
  ///
  /// Args:
  ///   context (BuildContext): The current context of the app.
  static String getRouteName(BuildContext context) {
    return ModalRoute.of(context)?.settings.name ?? '';
  }
// static logoutClearData(BuildContext context) {
//   String? tmp = PreferenceHelper.getString(PreferenceHelper.fcmToken) ??
//       PreferenceHelper.fcmToken;
//   PreferenceHelper.clear();
//   PreferenceHelper.setString(PreferenceHelper.fcmToken, tmp);
//   tmp = null;
//   Navigator.pushNamedAndRemoveUntil(
//       context, AppRoutes.routesLogin, (route) => false);
// }
}