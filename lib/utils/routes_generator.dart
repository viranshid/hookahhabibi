import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/Location/View/HHLocationScreen.dart';
import 'package:hookahhabibi/Screen/SplashScreen.dart';
import 'package:hookahhabibi/Screen/Login/HHLogin.dart';
import 'package:hookahhabibi/Screen/Welcom/View/HHWelcom.dart';
import 'package:hookahhabibi/utils/app_routes.dart';
import 'package:hookahhabibi/utils/CustomPageRoute.dart';

/// RouteGenerator with smooth animations
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print("Generating route for: ${settings.name}");
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.routesSplash:
        return FadePageRouteBuilder(
          builder: (_) => const SplashScreen(),
        );

      case AppRoutes.routesLogin:
        return FadePageRouteBuilder(
          builder: (_) => const HHLogin(),
        );

      case AppRoutes.routesWelcome:
        return CustomPageRouteBuilder(
          builder: (_) => const HHWelcome(),
        );

      case AppRoutes.routesLocation:
        return ScalePageRouteBuilder(
          builder: (_) => const HHLocationScreen(),
        );

      default:
        return FadePageRouteBuilder(
          builder: (_) => const SplashScreen(),
        );
    }
  }

  /// Get current route name
  static String getRouteName(BuildContext context) {
    return ModalRoute.of(context)?.settings.name ?? '';
  }

  /// Navigate with custom animation
  static Future<T?> navigateWithAnimation<T>(
      BuildContext context,
      Widget page, {
        AnimationType animationType = AnimationType.slide,
      }) {
    PageRouteBuilder<T> route;

    switch (animationType) {
      case AnimationType.fade:
        route = PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
        break;

      case AnimationType.scale:
        route = PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            );
            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            );
            return ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(opacity: fadeAnimation, child: child),
            );
          },
        );
        break;

      case AnimationType.slideFromRight:
        route = PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var tween = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOutCubic));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
        break;

      case AnimationType.slide:
      default:
        route = PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var tween = Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOutCubic));
            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
              ),
            );
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(opacity: fadeAnimation, child: child),
            );
          },
        );
    }

    return Navigator.push<T>(context, route);
  }

  /// Navigate and replace with animation
  static Future<T?> navigateAndReplaceWithAnimation<T>(
      BuildContext context,
      Widget page, {
        AnimationType animationType = AnimationType.fade,
      }) {
    PageRouteBuilder<T> route;

    switch (animationType) {
      case AnimationType.fade:
        route = PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
        break;

      case AnimationType.scale:
        route = PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            );
            return ScaleTransition(scale: scaleAnimation, child: child);
          },
        );
        break;

      default:
        route = PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
    }

    return Navigator.pushReplacement<T, void>(context, route);
  }
}

/// Animation types for navigation
enum AnimationType {
  fade,
  slide,
  slideFromRight,
  scale,
}