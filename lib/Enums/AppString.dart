import 'package:flutter/widgets.dart';
import 'package:hookahhabibi/l10n/app_localizations.dart';


enum AppString {
  loginTitle('Welcome back!'),
  loginSubTitle('Please Sign in to continue.'),
  loginEmailLbl('Email or Phone Number'),
  loginEmailSH('Enter your email'),
  loginPasswordLbl('Enter Password'),
  loginPasswordSH('Enter Password'),
  loginBtn('Sign In'),
  loginForgotBtn('Forgot Password?');

  final String defaultText;
  const AppString(this.defaultText);

  String text(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return defaultText;

    switch (this) {
      case AppString.loginTitle:
        return l10n.loginTitle;
      case AppString.loginSubTitle:
        return l10n.loginSubTitle;
      case AppString.loginEmailLbl:
        return l10n.loginEmailLbl;
      case AppString.loginEmailSH:
        return l10n.loginEmailSH;
      case AppString.loginPasswordLbl:
        return l10n.loginPasswordLbl;
      case AppString.loginPasswordSH:
        return l10n.loginPasswordSH;
      case AppString.loginBtn:
        return l10n.loginBtn;
      case AppString.loginForgotBtn:
        return l10n.loginForgotBtn;
    }
  }
}
