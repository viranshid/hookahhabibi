import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHOrderManager.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishCategoryModel.dart';
import 'package:hookahhabibi/Screen/Menu/Model/HHDishModel.dart';
import 'package:hookahhabibi/Screen/Menu/View/HHMenuListCard.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHKotItemModel.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHOrderModel.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHSelectedMealItem.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHStaffBookingSelection.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/StaffMenuTab.dart';
import 'package:hookahhabibi/Screen/Orders/View/Components/HHSplitOrderBillModal.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Components/HHKotPanel.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Components/HHOrderItemNotesCard.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Components/HHStaffMenuContentArea.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';

class HHMenuTabScreen extends StatefulWidget {
  /// Customer + selected tables + floor captured from the Tables tab. Used
  /// to populate the KOT panel header on the right. Falls back to the
  /// `empty` sentinel ("—") when the user opens the tab directly without
  /// having gone through the Tables-tab Continue flow.
  final HHStaffBookingSelection booking;

  /// Switches the parent [HHStaffMenuScreen] to a different tab after a
  /// successful place-order.
  final ValueChanged<StaffMenuTab>? onRequestTab;

  const HHMenuTabScreen({
    Key? key,
    this.booking = HHStaffBookingSelection.empty,
    this.onRequestTab,
  }) : super(key: key);

  @override
  State<HHMenuTabScreen> createState() => _HHMenuTabScreenState();
}

class _HHMenuTabScreenState extends State<HHMenuTabScreen> {
  static const Color _headerColor = Color(0xFFD09843);
  static const double _headerHeight = 50;
  static const double _headerTextBottomPadding = 9;
  static const double _headerWidth = 90;

  HHDishCategoryModel? _selectedCategory;
  final List<HHSelectedMealItem> _selectedMeals = [];
  bool _isPlacingOrder = false;
  HHOrderModel? _lastSavedOrder;

  void _handleItemSelected(HHDishModel dish) {
    setState(() {
      final index = _selectedMeals.indexWhere((m) => m.id == dish.id);
      if (index >= 0) {
        final existing = _selectedMeals[index];
        _selectedMeals[index] =
            existing.copyWith(quantity: existing.quantity + 1);
      } else {
        final priceSource =
            dish.rawPrice.isNotEmpty ? dish.rawPrice : dish.price;
        final breadcrumb = dish.fullCategory.isNotEmpty
            ? dish.fullCategory
            : [_selectedCategory?.title ?? '', dish.category]
                .where((s) => s.isNotEmpty)
                .join(' > ');
        _selectedMeals.add(HHSelectedMealItem(
          id: dish.id,
          title: dish.name,
          unitPrice: HHSelectedMealItem.parsePrice(priceSource),
          imageUrl: dish.imageUrl,
          subtitle: breadcrumb,
        ));
      }
    });
  }

  void _incrementItem(String id) {
    setState(() {
      final index = _selectedMeals.indexWhere((m) => m.id == id);
      if (index < 0) return;
      final item = _selectedMeals[index];
      _selectedMeals[index] = item.copyWith(quantity: item.quantity + 1);
    });
  }

  void _decrementItem(String id) {
    setState(() {
      final index = _selectedMeals.indexWhere((m) => m.id == id);
      if (index < 0) return;
      final item = _selectedMeals[index];
      if (item.quantity <= 1) {
        _selectedMeals.removeAt(index);
      } else {
        _selectedMeals[index] = item.copyWith(quantity: item.quantity - 1);
      }
    });
  }

  void _removeItem(String id) {
    setState(() {
      _selectedMeals.removeWhere((m) => m.id == id);
    });
  }

  Future<void> _handleAddNote(String id) async {
    final index = _selectedMeals.indexWhere((m) => m.id == id);
    if (index < 0) return;
    final item = _selectedMeals[index];
    final note = await HHOrderItemNotesCard.show(
      context,
      dishTitle: item.title,
      dishSubtitle: item.subtitle ?? '',
      imageUrl: item.imageUrl,
      initialNote: item.notes,
    );
    if (note == null) return;
    final latestIndex = _selectedMeals.indexWhere((m) => m.id == id);
    if (latestIndex < 0) return;
    setState(() {
      _selectedMeals[latestIndex] =
          _selectedMeals[latestIndex].copyWith(notes: note);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth =
        screenWidth - Dimens.margin90 - Dimens.margin300;

    return Container(
      color: AppColors.color01110A,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HHMenuListCard(
            isMenuOpen: false,
            collapsedWidth: Dimens.margin105,
            selectedMenuItem: _selectedCategory,
            onMenuItemSelected: (category) {
              setState(() => _selectedCategory = category);
            },
            header: _buildMenuDishesHeader(),
          ),
          Expanded(
            child: HHStaffMenuContentArea(
              selectedCategoryId: _selectedCategory?.id,
              contentWidth: contentWidth > 0 ? contentWidth : screenWidth,
              onItemSelected: _handleItemSelected,
            ),
          ),
          HHKotPanel(
            customerName: widget.booking.customerName,
            tableLabel: widget.booking.tableLabel,
            floorLabel: widget.booking.floorLabel,
            selectedItems: _selectedMeals,
            onIncrementItem: _incrementItem,
            onDecrementItem: _decrementItem,
            onRemoveItem: _removeItem,
            onAddNote: _handleAddNote,
            isPlacingOrder: _isPlacingOrder,
            onSendToKitchen: _onSendToKitchen,
            onSave: _onSave,
            onKotAndPrint: _onKotAndPrint,
            onSplit: _onSplit,
          ),
        ],
      ),
    );
  }

  // -------------------- ACTION HANDLERS --------------------

  /// "Save" — per UX decision, same as Send to Kitchen.
  void _onSave() => _placeOrder(printAfter: false);

  /// "KOT & Print" — place the order, then open a print preview on success.
  /// Print integration isn't wired yet; for now we surface a snackbar so
  /// the user knows the order landed but the printer step is pending.
  void _onKotAndPrint() => _placeOrder(printAfter: true);

  /// Primary CTA. Identical to "Save" in API behaviour.
  void _onSendToKitchen() => _placeOrder(printAfter: false);

  /// Place an order via /api/save-order-with-kot using the current cart
  /// ([_selectedMeals]) and the booking snapshot ([widget.booking]).
  Future<void> _placeOrder({required bool printAfter}) async {
    if (_isPlacingOrder) return;

    // ----- Pre-flight validation -----
    if (_selectedMeals.isEmpty) {
      _showSnack('Add at least one item before sending the order.');
      return;
    }
    final booking = widget.booking;
    if (!booking.canPlaceOrder) {
      _showSnack(
        'Select a table and customer on the Tables tab before placing an order.',
      );
      return;
    }

    // Map cart → API items. Cart `id` is a String dish id; parse to int.
    final items = <HHOrderItemRequest>[];
    for (final m in _selectedMeals) {
      final dishId = int.tryParse(m.id);
      if (dishId == null) continue;
      items.add(HHOrderItemRequest(
        dishId: dishId,
        quantity: m.quantity,
        dishTitle: m.title,
        dishSubtitle: null, // Variant tracking not in cart UI yet.
        dishPrice: m.unitPrice,
        notes: m.notes,
      ));
    }
    if (items.isEmpty) {
      _showSnack('Cart items are missing dish ids — cannot place order.');
      return;
    }

    setState(() => _isPlacingOrder = true);

    final manager = HHOrderManager();
    final order = await manager.createOrderWithKot(
      locationId: booking.locationId!,
      tableId: booking.tableIds.first,
      customerId: booking.customerId,
      customerName: booking.customerId == null ? booking.customerName : null,
      customerPhone: booking.customerId == null ? booking.customerPhone : null,
      guestCount: booking.guestCount,
      items: items,
    );

    if (!mounted) return;
    setState(() => _isPlacingOrder = false);

    if (order == null) {
      _showSnack(manager.error ?? 'Failed to place order. Please try again.');
      return;
    }

    // Success — clear the cart so the next round starts fresh.
    setState(() {
      _selectedMeals.clear();
      _lastSavedOrder = order;
    });
    _showSnack(
      printAfter
          ? 'Order #${order.id} placed. Printing… (printer integration pending)'
          : 'Order #${order.id} placed.',
    );

    // Jump to the Orders tab so staff can see it land.
    widget.onRequestTab?.call(StaffMenuTab.orders);
  }

  Future<void> _onSplit() async {
    final order = _lastSavedOrder;
    // Prefer real KOT items from the saved order; otherwise fall back to the
    // current cart so staff can preview / configure the split before the
    // order has been placed. With orderId=0 the Save call will fail at the
    // API and surface an inline error inside the modal — that's expected.
    final int orderId = order?.id ?? 0;
    final List<HHKotItemModel> kotItems;
    if (order != null && order.kots.isNotEmpty) {
      kotItems = [
        for (final kot in order.kots) ...kot.items,
      ];
    } else {
      kotItems = [
        for (final m in _selectedMeals)
          HHKotItemModel(
            id: int.tryParse(m.id) ?? 0,
            orderId: orderId,
            kotId: 0,
            dishId: int.tryParse(m.id) ?? 0,
            dishName: m.title,
            dishTitle: m.title,
            dishSubtitle: m.subtitle,
            quantity: m.quantity,
            dishPrice: m.unitPrice,
            lineTotal: m.totalPrice,
            status: '',
            statusLabel: '',
          ),
      ];
    }
    final ok = await HHSplitOrderBillModal.show(
      context,
      orderId: orderId,
      items: kotItems,
    );
    if (ok == true && mounted) {
      _showSnack('Bill split for order #$orderId.');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildMenuDishesHeader() {
    return Container(
      width: _headerWidth,
      height: _headerHeight,
      color: _headerColor,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: _headerTextBottomPadding),
      child: AppText(
        text: 'MENU DISHES',
        appTextStyle: AppTextStyle.oswaldRegular14UppercaseLight,
        customColor: AppColors.colorFFFFFF,
        textAlign: TextAlign.center,
      ),
    );
  }
}
