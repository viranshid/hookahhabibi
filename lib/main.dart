import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hookahhabibi/l10n/app_localizations.dart';
import 'package:hookahhabibi/Managers/HHStorageManager.dart';
import 'package:hookahhabibi/Managers/HHSessionManager.dart';
import 'package:hookahhabibi/Managers/HHLockManager.dart';
import 'package:hookahhabibi/utils/app_routes.dart';
import 'package:hookahhabibi/utils/routes_generator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set landscape orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize storage
  await HHStorageManager().init();

  // Initialize session manager
  await HHSessionManager().initialize();

  // Initialize lock manager
  HHLockManager();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.routesSplash,
      onGenerateRoute: RouteGenerator.generateRoute,
      builder: (context, child) {
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.0,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
              boldText: false,
              accessibleNavigation: false,
              invertColors: false,
              highContrast: false,
              disableAnimations: false,
            ),
            child: child!,
          ),
        );
      },
      theme: ThemeData(
        textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.0),
        visualDensity: VisualDensity.standard,
      ),
    );
  }
}