import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hookahhabibi/l10n/app_localizations.dart';
import 'package:hookahhabibi/Managers/HHAppManager.dart';
import 'package:hookahhabibi/Managers/HHStorageManager.dart';
import 'package:hookahhabibi/Managers/HHSessionManager.dart';
import 'package:hookahhabibi/Managers/HHLocationManager.dart';
import 'package:hookahhabibi/Managers/HHMenuManager.dart';
import 'package:hookahhabibi/Managers/HHLockManager.dart';
import 'package:hookahhabibi/utils/app_routes.dart';
import 'package:hookahhabibi/utils/routes_generator.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await HHStorageManager().init();
  await HHSessionManager().initialize();
  HHLockManager();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appManager = HHAppManager();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HHAppManager>.value(value: appManager),
        ChangeNotifierProvider<HHSessionManager>.value(value: appManager.sessionManager),
        ChangeNotifierProvider<HHLocationManager>.value(value: appManager.locationManager),
        ChangeNotifierProvider<HHMenuManager>.value(value: appManager.menuManager),
        ChangeNotifierProvider<HHLockManager>.value(value: appManager.lockManager),
      ],
      child: MaterialApp(
        localizationsDelegates: [AppLocalizations.delegate],
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
      ),
    );
  }
}
