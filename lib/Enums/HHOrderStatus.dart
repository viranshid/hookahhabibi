import 'package:flutter/material.dart';

enum HHOrderStatus {
  pending('Pending', Color(0xFFECC16E)),
  accepted('Accepted', Color(0xFF84994F)),
  inPreparation('In Preparation', Color(0xFFBD7D28)),
  readyServed('Ready / Served', Color(0xFF00C0E8)),
  completed('Completed', Color(0xFF00932E)),
  cancelled('Cancelled', Color(0xFFFF5F57));

  final String label;
  final Color indicatorColor;

  const HHOrderStatus(this.label, this.indicatorColor);

  bool get isTerminal => this == HHOrderStatus.completed || this == HHOrderStatus.cancelled;
}
