// ignore: unused_import
import 'package:intl/intl.dart';
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'Welcome back!';

  @override
  String get loginSubTitle => 'Please Sign in to continue.';

  @override
  String get loginEmailLbl => 'Email or Phone Number';

  @override
  String get loginEmailSH => 'Enter your email';

  @override
  String get loginPasswordLbl => 'Enter Password';

  @override
  String get loginPasswordSH => 'Enter Password';

  @override
  String get loginBtn => 'Sign In';

  @override
  String get loginForgotBtn => 'Forgot Password?';
}
