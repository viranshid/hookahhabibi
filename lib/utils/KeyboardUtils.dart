import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardUtils {
  /// Hide the keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// Force landscape orientation
  static void setLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Allow all orientations (for when needed)
  static void setAllOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Create a keyboard-aware wrapper widget
  static Widget buildKeyboardAware({
    required Widget child,
    bool enableAutoScroll = true,
    double scrollOffset = 100.0,
    ScrollController? scrollController,
  }) {
    return Builder(
      builder: (context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          transform: enableAutoScroll && isKeyboardVisible(context)
              ? Matrix4.translationValues(
            0.0,
            -getKeyboardHeight(context) * 0.3,
            0.0,
          )
              : Matrix4.identity(),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Mixin for widgets that need keyboard handling
mixin KeyboardHandlingMixin<T extends StatefulWidget> on State<T> {
  ScrollController? _scrollController;
  List<FocusNode> _focusNodes = [];

  ScrollController get scrollController {
    _scrollController ??= ScrollController();
    return _scrollController!;
  }

  /// Add a focus node to be managed
  void addFocusNode(FocusNode focusNode) {
    _focusNodes.add(focusNode);
    focusNode.addListener(_onFocusChange);
  }

  /// Remove a focus node
  void removeFocusNode(FocusNode focusNode) {
    focusNode.removeListener(_onFocusChange);
    _focusNodes.remove(focusNode);
  }

  /// Handle focus changes
  void _onFocusChange() {
    if (_focusNodes.any((node) => node.hasFocus)) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          scrollController.animateTo(
            100.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  /// Hide keyboard
  void hideKeyboard() {
    KeyboardUtils.hideKeyboard(context);
  }

  /// Check if keyboard is visible
  bool get isKeyboardVisible => KeyboardUtils.isKeyboardVisible(context);

  /// Clean up resources
  void disposeKeyboardHandling() {
    for (var focusNode in _focusNodes) {
      focusNode.removeListener(_onFocusChange);
    }
    _focusNodes.clear();
    _scrollController?.dispose();
  }
}

/// Custom scroll behavior for better keyboard handling
class KeyboardAwareScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}