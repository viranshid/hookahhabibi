# 🎨 Hookah Habibi UI Utilities Skill

## Purpose
Ensure all UI components use centralized utility files for colors, fonts, dimensions, strings, and images instead of hardcoded values. This maintains consistency, improves maintainability, and makes design changes easier.

## Utility Files & What They Contain

### 1. **Colors** → `lib/utils/app_colors.dart`
All colors used across the app are defined here.

**When to use:**
- Replace any `Color(0xFF...)` with `AppColors.colorXXXX`
- Add new colors here before using them in components

**Example:**
```dart
// ❌ BAD
color: Color(0xFF00541A),

// ✅ GOOD
color: AppColors.color00541A,
```

**Common colors:**
- `AppColors.color00541A` - Dark Green (primary)
- `AppColors.colorECC16E` - Gold (accent)
- `AppColors.colorD9D9D9` - Light Gray
- `AppColors.colorFFFFFF` - White
- `AppColors.colorBlack` - Black

---

### 2. **Dimensions & Spacing** → `lib/utils/app_dimens.dart`
All sizes, margins, padding, and dimensions defined here.

**When to use:**
- Replace any hardcoded number (20, 50, 100, etc.) with `Dimens.marginXX`
- Use for card heights, widths, border radius, gaps

**Example:**
```dart
// ❌ BAD
padding: EdgeInsets.all(20),
height: 120,
borderRadius: BorderRadius.circular(12),

// ✅ GOOD
padding: const EdgeInsets.all(Dimens.margin20),
height: Dimens.margin120,
borderRadius: BorderRadius.circular(12), // or use existing margin value
```

**Common values:**
- `Dimens.margin10`, `Dimens.margin12`, `Dimens.margin16`, `Dimens.margin20`, `Dimens.margin30`
- `Dimens.margin50`, `Dimens.margin100`, `Dimens.margin120`

---

### 3. **Text Styles** → `lib/utils/AppTextStyle.dart`
All typography styles (font family, size, weight, color) defined here.

**When to use:**
- Use AppTextStyle enum with `AppTextStyleManager.getStyle()` for predefined styles
- Or create consistent TextStyle using `AppTextStyle` enum

**Example:**
```dart
// ❌ BAD
style: TextStyle(
  fontFamily: 'Jost',
  fontSize: 30,
  fontWeight: FontWeight.bold,
  color: Color(0xFF00541A),
),

// ✅ GOOD - Use predefined enum
style: AppTextStyleManager.getStyle(AppTextStyle.jostBold26Heading),

// OR if no matching enum exists, create with named constants
static const double _fontSize = 30;
static const Color _fontColor = AppColors.color00541A;
```

---

### 4. **Images & Icons** → `lib/utils/app_images.dart`
All image paths and asset constants defined here.

**When to use:**
- Replace `'assets/images/...'` with `APPImages.icXXX` constant
- Add new image constants before using them

**Example:**
```dart
// ❌ BAD
Image.asset('assets/images/ic_staff_member.png'),

// ✅ GOOD
Image.asset(APPImages.icStaffMember),
```

**How to add new images:**
```dart
// In app_images.dart
static const icStaffMember = '${imageBaseURL}ic_staff_member.png';
static const icCustomer = '${imageBaseURL}ic_customer.png';

// Then use in code
Image.asset(APPImages.icStaffMember),
```

---

### 5. **Strings** → `lib/utils/app_Strings.dart`
All text labels, error messages, and copy defined here.

**When to use:**
- Replace all hardcoded text with `APPStrings.xxxxx` constants
- Helps with localization and consistency

**Example:**
```dart
// ❌ BAD
Text('Select User Type'),
_showSnackBar('Please select a location'),

// ✅ GOOD
Text(APPStrings.selectUserType),
_showSnackBar(APPStrings.selectLocation),
```

**How to add new strings:**
```dart
// In app_Strings.dart
static const String selectUserType = 'Select User Type';
static const String staffMember = 'Staff Member';
static const String customer = 'Customer';
```

---

## Best Practices for New UI Components

### 1. **Extract Magic Numbers to Constants**
```dart
class MyCustomCard extends StatelessWidget {
  // Define ALL design values as static constants at class level
  static const double _cardHeight = 120;
  static const double _borderRadius = 12;
  static const double _iconSize = 50;
  static const double _shadowBlur = 20;
  static const int _animationDuration = 300;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: _cardHeight, // ✅ Use constant
      borderRadius: BorderRadius.circular(_borderRadius),
      ...
    );
  }
}
```

### 2. **Import All Utility Files**
```dart
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';
import 'package:hookahhabibi/utils/app_Strings.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
```

### 3. **Document Design Values**
```dart
// ✅ Add comments explaining where design values come from
// Colors from Figma node-id=1611-18
static const Color _selectedBorderColor = AppColors.color00541A;
static const Color _unselectedBorderColor = AppColors.color00541A80;

// Typography from design spec
static const double _labelFontSize = 22;
static const double _labelLineHeight = 20 / 22;
```

---

## Checklist for Every UI Component

Before submitting code, verify:

- [ ] All colors use `AppColors.xxxx`
- [ ] All dimensions use `Dimens.marginXX`
- [ ] All text uses `APPStrings.xxxx`
- [ ] All images use `APPImages.icXXX`
- [ ] No hardcoded hex colors: `Color(0xFF...)`
- [ ] No hardcoded font families: use AppTextStyle
- [ ] No hardcoded strings
- [ ] Design values extracted to named constants (especially `static const`)
- [ ] Imports include all necessary utility files

---

## Example: Complete Refactored Component

```dart
import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/app_images.dart';
import 'package:hookahhabibi/utils/app_Strings.dart';

class UserTypeCard extends StatelessWidget {
  // Design constants
  static const double _cardHeight = 120;
  static const double _cardBorderRadius = 12;
  static const double _iconSize = 50;
  static const double _radioButtonSize = 20;
  static const double _shadowBlur = 20;
  static const int _animationDuration = 300;

  final bool isSelected;
  final VoidCallback onTap;

  const UserTypeCard({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: _animationDuration),
        height: _cardHeight,
        decoration: BoxDecoration(
          color: Colors.white, // ✅ Use AppColors.colorFFFFFF if needed
          borderRadius: BorderRadius.circular(_cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1F000000),
              blurRadius: _shadowBlur,
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(APPImages.icStaffMember, width: _iconSize),
            Text(APPStrings.staffMember),
            _buildRadioButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton() {
    return Container(
      width: _radioButtonSize,
      height: _radioButtonSize,
      decoration: BoxDecoration(
        color: AppColors.colorD9D9D9,
        border: Border.all(
          color: isSelected ? AppColors.color00541A : AppColors.color00541A80,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(_radioButtonSize / 2),
      ),
    );
  }
}
```

---

## When to Update Utility Files

### Add to `app_colors.dart`:
- New brand colors discovered in design
- New status colors (error, warning, success)
- Opacity variations of existing colors

### Add to `app_dimens.dart`:
- New spacing standard
- New card/component size
- Border radius values

### Add to `app_Strings.dart`:
- New screen labels
- New button text
- New error messages

### Add to `app_images.dart`:
- New icons
- New background images
- New placeholder graphics

---

## Troubleshooting

**Q: What if the color I need doesn't exist?**
A: Add it to `app_colors.dart` with a clear name:
```dart
static const colorMyFeatureGreen = Color(0xFFXXXXXX); // From Figma design spec
```

**Q: Should I create variables for every single value?**
A: No, only for:
- Values used more than once
- Values that might change (design system colors, spacing standards)
- Values important to document (from design specs)

Small, one-time constants can stay inline.

**Q: Can I use different font families?**
A: Use `AppTextStyle` enum or define typography in `app_Strings.dart`. All fonts should come from the design system, not arbitrary choices.

---

## Related Files
- Design tokens: `lib/utils/` folder
- Component examples: `lib/Screen/Location/View/HHUserTypeCard.dart`
- Main design system: `CLAUDE.md` → Design Tokens section
