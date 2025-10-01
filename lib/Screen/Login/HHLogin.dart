import 'package:flutter/material.dart';
import 'package:hookahhabibi/Enums/HHButtonType.dart';
import 'package:hookahhabibi/Managers/HHAppManager.dart';
import 'package:hookahhabibi/Screen/Location/View/HHLocationScreen.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/KeyboardUtils.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';
import 'package:hookahhabibi/utils/app_Strings.dart';
import 'package:hookahhabibi/widgets/HHTextField.dart';
import 'package:hookahhabibi/widgets/HHButton.dart';

class HHLogin extends StatefulWidget {
  const HHLogin({Key? key}) : super(key: key);

  @override
  State<HHLogin> createState() => _HHLoginState();
}

class _HHLoginState extends State<HHLogin> with KeyboardHandlingMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final HHAppManager _appManager = HHAppManager();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    KeyboardUtils.setLandscapeOrientation();
    addFocusNode(_emailFocusNode);
    addFocusNode(_passwordFocusNode);

    // For testing, pre-fill credentials
    _emailController.text = 'mt11@example.com';
    _passwordController.text = 'Test@123';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    disposeKeyboardHandling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: KeyboardUtils.buildKeyboardAware(
        scrollController: scrollController,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(APPImages.icLoginBg),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          _buildLogo(),
          _buildLoginBox(),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Positioned(
      top: Dimens.margin50,
      left: 0,
      right: 0,
      child: Center(
        child: Image.asset(
          APPImages.icLoginLogo,
          width: Dimens.margin350,
          height: Dimens.margin100,
        ),
      ),
    );
  }

  Widget _buildLoginBox() {
    return Positioned(
      top: Dimens.margin180,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          constraints: BoxConstraints(
            maxWidth: Dimens.margin480,
            minWidth: Dimens.margin400,
          ),
          decoration: BoxDecoration(
            color: AppColors.color171717.withOpacity(0.8),
            borderRadius: BorderRadius.circular(Dimens.margin10),
            border: Border.all(
              color: AppColors.color2B2B2B,
              width: Dimens.margin2,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(Dimens.margin40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWelcomeTitle(),
                SizedBox(height: Dimens.margin5),
                _buildWelcomeSubtitle(),
                SizedBox(height: Dimens.margin30),
                _buildEmailField(),
                SizedBox(height: Dimens.margin20),
                _buildPasswordField(),
                SizedBox(height: Dimens.margin30),
                _buildSignInButton(),
                SizedBox(height: Dimens.margin16),
                _buildForgotPasswordButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeTitle() {
    return AppText(
      text: APPStrings.loginTitle,
      appTextStyle: AppTextStyle.jostMedium30Primary,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildWelcomeSubtitle() {
    return AppText(
      text: APPStrings.loginSubTitle,
      appTextStyle: AppTextStyle.jostMedium16Primary,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: APPStrings.loginEmailLbl,
          appTextStyle: AppTextStyle.jostMedium16Gray,
          customColor: AppColors.color949494,
        ),
        SizedBox(height: Dimens.margin8),
        HHTextField(
          controller: _emailController,
          hintText: APPStrings.loginEmailSH,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: APPStrings.loginPasswordLbl,
          appTextStyle: AppTextStyle.jostMedium16Gray,
          customColor: AppColors.color949494,
        ),
        SizedBox(height: Dimens.margin8),
        HHTextField(
          controller: _passwordController,
          hintText: APPStrings.loginPasswordSH,
          isSecureField: true,
          focusNode: _passwordFocusNode,
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          onSubmitted: (_) => _handleSignIn(),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return HHButton(
      text: APPStrings.loginBtn,
      type: HHButtonType.normal,
      onPressed: _isLoading ? null : _handleSignIn,
      isEnabled: !_isLoading,
    );
  }

  Widget _buildForgotPasswordButton() {
    return HHButton(
      text: APPStrings.loginForgotBtn,
      type: HHButtonType.onlyText,
      onPressed: _isLoading ? null : _handleForgotPassword,
      isEnabled: !_isLoading,
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorECC16E),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    hideKeyboard();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validation
    if (email.isEmpty) {
      _showSnackBar('Please enter your email or phone number');
      return;
    }

    if (password.isEmpty) {
      _showSnackBar('Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call API through AppManager
      final response = await _appManager.login(
        email: email,
        password: password,
      );

      if (response.success) {
        // Login successful, navigate to location screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HHLocationScreen(),
            ),
          );
        }
      } else {
        // Login failed
        _showSnackBar(response.message ?? 'Login failed');
      }
    } catch (e) {
      _showSnackBar('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword() {
    hideKeyboard();
    _showSnackBar('Forgot password feature coming soon');
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.colorBD7D28,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}