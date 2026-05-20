import 'package:flutter/material.dart';
import 'package:hookahhabibi/Enums/HHOrderStatus.dart';
import 'package:hookahhabibi/Screen/StaffMenu/Model/HHOrderModel.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Components/HHOrderKOTCard.dart';
import 'package:hookahhabibi/Screen/StaffMenu/View/Components/HHOrderStatusHeader.dart';
import 'package:hookahhabibi/utils/app_colors.dart';

class HHOrdersTabScreen extends StatefulWidget {
  const HHOrdersTabScreen({Key? key}) : super(key: key);

  @override
  State<HHOrdersTabScreen> createState() => _HHOrdersTabScreenState();
}

class _HHOrdersTabScreenState extends State<HHOrdersTabScreen> {
  HHOrderStatus? _activeStatus;

  static const _sampleItems = <HHOrderItem>[
    HHOrderItem(name: 'Goat Seekh', qty: 1),
    HHOrderItem(name: 'Tandoor Chicken', qty: 2),
    HHOrderItem(name: 'Hummus', qty: 1),
    HHOrderItem(name: 'Naingra Kebab', qty: 1),
    HHOrderItem(name: 'Falafel Plate', qty: 1),
  ];

  late final List<HHOrderModel> _orders = [
    _make('1', 'Vishakha', '4', HHOrderStatus.pending),
    _make('2', 'Aman', '7', HHOrderStatus.accepted),
    _make('3', 'Rahul', '2', HHOrderStatus.completed),
    _make('4', 'Priya', '9', HHOrderStatus.readyServed),
    _make('5', 'Sara', '1', HHOrderStatus.readyServed),
    _make('6', 'Kabir', '3', HHOrderStatus.completed),
    _make('7', 'Neha', '5', HHOrderStatus.completed),
    _make('8', 'Omar', '6', HHOrderStatus.cancelled),
  ];

  HHOrderModel _make(String id, String name, String table, HHOrderStatus status) {
    return HHOrderModel(
      id: id,
      customerName: name,
      tableNumber: table,
      viewCount: 2,
      status: status,
      kotEntries: [
        HHKotEntry(kotNumber: 1, time: '22:00', items: _sampleItems),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _activeStatus == null
        ? _orders
        : _orders.where((o) => o.status == _activeStatus).toList();

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
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(15, 14, 16, 14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 19,
                mainAxisSpacing: 21,
                mainAxisExtent: HHOrderKOTCard.cardHeight,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return Center(child: HHOrderKOTCard(order: filtered[index]));
              },
            ),
          ),
        ],
      ),
    );
  }
}
