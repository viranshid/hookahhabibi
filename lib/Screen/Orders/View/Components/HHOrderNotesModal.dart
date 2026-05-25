import 'package:flutter/material.dart';
import 'package:hookahhabibi/Managers/HHOrderManager.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_images.dart';
import 'package:provider/provider.dart';

/// Modal for adding / editing an order's note (top-level `notes` field).
///
/// Returns `true` via [Navigator.pop] after a successful
/// /api/edit-order-note call, `null` on Cancel / close.
class HHOrderNotesModal extends StatefulWidget {
  const HHOrderNotesModal({
    Key? key,
    required this.orderId,
    required this.customerName,
    required this.tableNumber,
    this.floorLabel = 'Ground Floor',
    this.initialNote,
  }) : super(key: key);

  final int orderId;
  final String customerName;
  final String tableNumber;
  final String floorLabel;
  final String? initialNote;

  static Future<bool?> show(
    BuildContext context, {
    required int orderId,
    required String customerName,
    required String tableNumber,
    String floorLabel = 'Ground Floor',
    String? initialNote,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x99000000),
      builder: (_) => HHOrderNotesModal(
        orderId: orderId,
        customerName: customerName,
        tableNumber: tableNumber,
        floorLabel: floorLabel,
        initialNote: initialNote,
      ),
    );
  }

  @override
  State<HHOrderNotesModal> createState() => _HHOrderNotesModalState();
}

class _HHOrderNotesModalState extends State<HHOrderNotesModal> {
  static const double _modalWidth = 600;
  static const double _modalHeight = 326;

  late final TextEditingController _noteController;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: SizedBox(
          width: _modalWidth,
          height: _modalHeight,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.color004216,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 30),
                  blurRadius: 30,
                  spreadRadius: -10,
                  color: Color(0x1F000000),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    Container(
                      height: 1,
                      color: const Color(0x33FFFFFF),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                        child: Column(
                          children: [
                            Expanded(child: _buildNoteInput()),
                            const SizedBox(height: 15),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _isSubmitting ? null : _close,
                    child: Image.asset(
                      APPImages.icNoteCloseBtn,
                      width: 24,
                      height: 24,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.cancel,
                        size: 24,
                        color: Color(0xFFFF5F57),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    const labelStyle = TextStyle(
      fontFamily: 'Oswald',
      fontWeight: FontWeight.w500,
      fontSize: 16,
      height: 20 / 16,
      color: Color(0xFFFFFFFF),
    );

    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 44),
        child: Row(
          children: [
            Text('ID : #${widget.orderId}', style: labelStyle),
            _divider(),
            Image.asset(
              APPImages.icMenuTabPerson,
              width: 26,
              height: 26,
            ),
            const SizedBox(width: 5),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                widget.customerName,
                style: labelStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _divider(),
            Image.asset(
              APPImages.icMenuTabTable,
              width: 26,
              height: 26,
            ),
            const SizedBox(width: 5),
            Text(
              'T-${widget.tableNumber}',
              style: const TextStyle(
                fontFamily: 'Oswald',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 16 / 16,
                color: Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(width: 15),
            _buildFloorChip(),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      color: const Color(0x33FFFFFF),
    );
  }

  Widget _buildFloorChip() {
    return Container(
      width: 100,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.color266528,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppColors.color266528, width: 1),
      ),
      child: Text(
        widget.floorLabel,
        style: const TextStyle(
          fontFamily: 'Oswald',
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 20 / 16,
          color: Color(0xFFFFFFFF),
        ),
      ),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      constraints: const BoxConstraints(minHeight: 170),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x80171717),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x3301110A), width: 1),
      ),
      child: TextField(
        controller: _noteController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        cursorColor: const Color(0xFFF4F7F4),
        enabled: !_isSubmitting,
        style: const TextStyle(
          fontFamily: 'Oswald',
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 1.2,
          color: Color(0xFFF4F7F4),
        ),
        decoration: const InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: 'Add a note for the kitchen / staff...',
          hintStyle: TextStyle(
            fontFamily: 'Oswald',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Color(0x66F4F7F4),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontFamily: 'Oswald',
                fontSize: 13,
                color: Color(0xFFFF5F57),
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _pill(
              label: 'Cancel',
              background: const Color(0x33000000),
              weight: FontWeight.w400,
              onPressed: _isSubmitting ? null : _close,
            ),
            const SizedBox(width: 10),
            _pill(
              label: 'Add Note',
              background: AppColors.colorBD7D28,
              weight: FontWeight.w500,
              loading: _isSubmitting,
              onPressed: _isSubmitting ? null : _onAddNotePressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _pill({
    required String label,
    required Color background,
    required FontWeight weight,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return SizedBox(
      width: 140,
      height: 46,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(60),
        child: InkWell(
          borderRadius: BorderRadius.circular(60),
          onTap: onPressed,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFFFFF),
                      ),
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Oswald',
                      fontWeight: weight,
                      fontSize: 20,
                      height: 1.0,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _close() => Navigator.of(context).pop();

  Future<void> _onAddNotePressed() async {
    final note = _noteController.text.trim();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final manager = context.read<HHOrderManager>();
    final result = await manager.editOrderNote(
      orderId: widget.orderId,
      note: note,
    );

    if (!mounted) return;
    if (result != null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isSubmitting = false;
      _errorMessage = manager.error ?? 'Failed to update note.';
    });
  }
}
