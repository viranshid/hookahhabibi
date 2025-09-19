
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hookahhabibi/utils/app_routes.dart';
import 'package:hookahhabibi/utils/routes_generator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        // Visual density fixed રાખો
        visualDensity: VisualDensity.standard,
      ),
    );
  }
}