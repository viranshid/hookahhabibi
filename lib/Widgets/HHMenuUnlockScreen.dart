import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hookahhabibi/Enums/HHButtonType.dart';
import 'package:hookahhabibi/Managers/HHSessionManager.dart';
import 'package:hookahhabibi/Managers/HHLockManager.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';
import 'package:hookahhabibi/widgets/HHButton.dart';

class HHMenuUnlockScreen extends StatefulWidget {
  final VoidCallback? onUnlocked;
  final VoidCallback? onCancel;

  const HHMenuUnlockScreen({
    Key? key,
    this.onUnlocked,
    this.onCancel,
  }) : super(key: key);

  @override
  State<HHMenuUnlockScreen> createState() => _HHMenuUnlockScreenState();
}

class _HHMenuUnlockScreenState extends State<HHMenuUnlockScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _pinControllers = List.generate(
    4,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
        (index) => FocusNode(),
  );
  final HHSessionManager _sessionManager = HHSessionManager();
  final HHLockManager _lockManager = HHLockManager();

  bool _isUnlocking = false;
  bool _showError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkLockoutStatus();

    // Auto focus first field if not locked out
    if (!_lockManager.isLockedOut) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  void _setupAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );
  }

  void _checkLockoutStatus() {
    if (_lockManager.isLockedOut) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    _remainingSeconds = _lockManager.remainingLockoutSeconds;
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds = _lockManager.remainingLockoutSeconds;

          if (_remainingSeconds <= 0) {
            timer.cancel();
            // Auto focus first field after lockout expires
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                _focusNodes[0].requestFocus();
              }
            });
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  String _getEnteredPin() {
    return _pinControllers.map((c) => c.text).join();
  }

  void _handlePinInput(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    setState(() {
      _showError = false;
    });
  }

  void _handleBackspace(int index) {
    if (_pinControllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _pinControllers[index - 1].clear();
    }
  }

  Future<void> _handleUnlock() async {
    // Check if locked out
    if (_lockManager.isLockedOut) {
      _showErrorMessage('Too many attempts. Please wait $_remainingSeconds seconds.');
      return;
    }

    final enteredPin = _getEnteredPin();

    if (enteredPin.length < 4) {
      _showErrorMessage('Please enter all 4 digits');
      return;
    }

    setState(() {
      _isUnlocking = true;
      _showError = false;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final user = _sessionManager.currentUser;
    final correctPin = user?.lockScreenPin;

    final success = await _lockManager.attemptUnlock(enteredPin, correctPin);

    if (success) {
      widget.onUnlocked?.call();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() {
        _isUnlocking = false;
        _showError = true;
      });

      _shakeBox();
      _clearPin();

      if (_lockManager.isLockedOut) {
        _showErrorMessage(
            'Too many failed attempts. Please wait ${HHLockManager.lockoutDurationSeconds} seconds.'
        );
        _startCountdown();
      } else {
        _showErrorMessage(
            'Incorrect PIN. ${_lockManager.remainingAttempts} ${_lockManager.remainingAttempts == 1 ? "attempt" : "attempts"} remaining.'
        );
      }
    }
  }

  void _shakeBox() {
    _shakeController.forward(from: 0).then((_) {
      _shakeController.reverse();
    });
  }

  void _clearPin() {
    for (var controller in _pinControllers) {
      controller.clear();
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && !_lockManager.isLockedOut) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFCD3030),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(Dimens.margin20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.margin10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onCancel?.call();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value * (_showError ? 1 : 0), 0),
                    child: child,
                  );
                },
                child: _buildUnlockBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockBox() {
    final isLockedOut = _lockManager.isLockedOut;

    return Container(
      width: Dimens.margin420,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xBF000000),
        borderRadius: BorderRadius.circular(Dimens.margin10),
        border: Border.all(
          color: const Color(0x1A969696),
          width: Dimens.margin5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            offset: Offset(0, 20),
            blurRadius: 65,
            spreadRadius: -15,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Dimens.margin30,
          horizontal: Dimens.margin20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitle(),
            SizedBox(height: Dimens.margin20),
            _buildSubtitle(),
            if (isLockedOut) ...[
              SizedBox(height: Dimens.margin20),
              _buildLockoutMessage(),
            ],
            SizedBox(height: Dimens.margin25),
            _buildPinInputs(),
            SizedBox(height: Dimens.margin25),
            _buildUnlockButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Menu Screen Unlock',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Oswald',
        fontWeight: FontWeight.w500,
        fontSize: 28,
        height: 1.2,
        letterSpacing: 0,
        color: Color(0xFFF4F5F7),
      ),
    );
  }

  Widget _buildSubtitle() {
    String text;
    Color color;

    if (_lockManager.isLockedOut) {
      text = 'Too Many Failed Attempts';
      color = const Color(0xFFCD3030);
    } else if (_showError) {
      text = 'Incorrect PIN - Try Again';
      color = const Color(0xFFCD3030);
    } else {
      text = 'Enter Unlock Pin';
      color = AppColors.color949494;
    }

    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Oswald',
        fontWeight: FontWeight.w400,
        fontSize: Dimens.textSize16,
        height: 1.25,
        letterSpacing: 0,
        color: color,
      ),
    );
  }

  Widget _buildLockoutMessage() {
    return Container(
      padding: const EdgeInsets.all(Dimens.margin12),
      decoration: BoxDecoration(
        color: const Color(0xFFCD3030).withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimens.margin8),
        border: Border.all(
          color: const Color(0xFFCD3030),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.timer,
            color: Color(0xFFCD3030),
            size: 20,
          ),
          SizedBox(width: Dimens.margin8),
          Text(
            'Wait $_remainingSeconds seconds',
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFFCD3030),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinInputs() {
    final isLockedOut = _lockManager.isLockedOut;

    return Opacity(
      opacity: isLockedOut ? 0.5 : 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Container(
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : Dimens.margin12,
            ),
            child: _buildPinBox(index, enabled: !isLockedOut),
          );
        }),
      ),
    );
  }

  Widget _buildPinBox(int index, {required bool enabled}) {
    return Container(
      width: Dimens.margin56,
      height: Dimens.margin56,
      decoration: BoxDecoration(
        color: AppColors.color171717,
        borderRadius: BorderRadius.circular(Dimens.margin6),
        border: Border.all(
          color: _showError ? const Color(0xFFCD3030) : AppColors.color2B2B2B,
          width: Dimens.margin1,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _pinControllers[index],
          focusNode: _focusNodes[index],
          enabled: enabled,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          obscureText: true,
          obscuringCharacter: '●',
          style: const TextStyle(
            color: AppColors.colorFFFFFF,
            fontSize: Dimens.textSize24,
            fontWeight: FontWeight.w600,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          onChanged: (value) => _handlePinInput(index, value),
          onTap: () {
            if (enabled) {
              _pinControllers[index].clear();
            }
          },
        ),
      ),
    );
  }

  Widget _buildUnlockButton() {
    final isLockedOut = _lockManager.isLockedOut;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.margin40),
      child: HHButton(
        text: isLockedOut ? 'Locked Out' : 'Unlock Screen',
        type: HHButtonType.iconWithText,
        imagePath: APPImages.icLock,
        height: Dimens.margin56,
        backgroundColor: isLockedOut
            ? AppColors.color949494
            : const Color(0xFFBD7D28),
        onPressed: (_isUnlocking || isLockedOut) ? null : _handleUnlock,
        isEnabled: !_isUnlocking && !isLockedOut,
      ),
    );
  }
}