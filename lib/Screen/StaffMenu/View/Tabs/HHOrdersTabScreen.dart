import 'package:flutter/material.dart';
import 'package:hookahhabibi/Enums/HHOrderStatus.dart';
import 'package:hookahhabibi/Managers/HHOrderManager.dart';
import 'package:hookahhabibi/Screen/Orders/Model/HHOrderModel.dart' as api_order;
import 'package:hookahhabibi/Screen/Orders/View/Components/HHOrderNotesModal.dart';
import 'package:hookahhabibi/Screen/Orders/View/Components/HHSplitOrderBillModal.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHOrderModel.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Components/HHOrderKOTCard.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Components/HHOrderStatusHeader.dart';
import 'package:hookahhabibi/Widgets/HHErrorView.dart';
import 'package:hookahhabibi/Widgets/HHLoadingView.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:provider/provider.dart';

class HHOrdersTabScreen extends StatefulWidget {
  const HHOrdersTabScreen({Key? key}) : super(key: key);

  @override
  State<HHOrdersTabScreen> createState() => _HHOrdersTabScreenState();
}

class _HHOrdersTabScreenState extends State<HHOrdersTabScreen> {
  HHOrderStatus? _activeStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HHOrderManager>().loadOrders();
    });
  }

  Future<void> _refresh() async {
    await context.read<HHOrderManager>().loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final orderManager = context.watch<HHOrderManager>();
    final apiOrders = orderManager.orders;

    final pairs = apiOrders
        .map((src) => _OrderPair(apiOrder: src, ui: HHOrderModel.fromApi(src)))
        .toList();
    final filtered = _activeStatus == null
        ? pairs
        : pairs.where((p) => p.ui.status == _activeStatus).toList();

    return Container(
      color: AppColors.color01110A,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HHOrderStatusHeader(
            selectedStatus: _activeStatus,
            onStatusSelected: (s) => setState(() {
              _activeStatus = _activeStatus == s ? null : s;
            }),
            onNewOrderPressed: () {},
          ),
          Expanded(child: _buildBody(orderManager, filtered)),
        ],
      ),
    );
  }

  Widget _buildBody(HHOrderManager mgr, List<_OrderPair> orders) {
    if (mgr.isLoadingList && mgr.orders.isEmpty) {
      return const HHLoadingView(message: 'Loading orders...');
    }
    if (mgr.error != null && mgr.orders.isEmpty) {
      return HHErrorView(
        message: mgr.error!,
        retryLabel: 'Retry',
        onRetry: _refresh,
      );
    }
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No orders found',
          style: TextStyle(color: Colors.white70, fontFamily: 'Oswald'),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(15, 14, 16, 14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 19,
          mainAxisSpacing: 21,
          mainAxisExtent: HHOrderKOTCard.cardHeight,
        ),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final pair = orders[index];
          return Center(
            child: HHOrderKOTCard(
              order: pair.ui,
              onTransfer: () => _openSplitBill(pair.apiOrder),
              onViewBill: () => _openOrderNote(pair.apiOrder),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openOrderNote(api_order.HHOrderModel order) async {
    final result = await HHOrderNotesModal.show(
      context,
      orderId: order.id,
      customerName: order.customer?.name ?? '—',
      tableNumber: order.table?.tableNumber ?? '—',
      initialNote: order.notes,
    );
    if (result == true && mounted) {
      _refresh();
    }
  }

  Future<void> _openSplitBill(api_order.HHOrderModel order) async {
    final items = [
      for (final kot in order.kots) ...kot.items,
    ];
    final result = await HHSplitOrderBillModal.show(
      context,
      orderId: order.id,
      items: items,
    );
    if (result == true && mounted) {
      _refresh();
    }
  }
}

class _OrderPair {
  final api_order.HHOrderModel apiOrder;
  final HHOrderModel ui;
  const _OrderPair({required this.apiOrder, required this.ui});
}
