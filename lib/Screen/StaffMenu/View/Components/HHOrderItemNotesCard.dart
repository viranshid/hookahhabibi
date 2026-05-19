import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_images.dart';

/// Modal popup that lets staff attach a free-text note to a selected meal item.
///
/// Returns the trimmed note via [Navigator.pop] when **Add Note** is tapped,
/// or `null` if Cancel, the close button, or the barrier dismisses the dialog.
class HHOrderItemNotesCard extends StatefulWidget {
  const HHOrderItemNotesCard({
    Key? key,
    required this.dishTitle,
    required this.dishSubtitle,
    this.imageUrl,
    this.initialNote,
  }) : super(key: key);

  final String dishTitle;
  final String dishSubtitle;
  final String? imageUrl;
  final String? initialNote;

  static Future<String?> show(
    BuildContext context, {
    required String dishTitle,
    required String dishSubtitle,
    String? imageUrl,
    String? initialNote,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x99000000),
      builder: (_) => HHOrderItemNotesCard(
        dishTitle: dishTitle,
        dishSubtitle: dishSubtitle,
        imageUrl: imageUrl,
        initialNote: initialNote,
      ),
    );
  }

  @override
  State<HHOrderItemNotesCard> createState() => _HHOrderItemNotesCardState();
}

class _HHOrderItemNotesCardState extends State<HHOrderItemNotesCard> {
  late final TextEditingController _controller;

  static const double _cardWidth = 600;
  static const double _cardHeight = 276;
  static const double _imageSize = 70;

  static const Color _noteFieldFill = Color(0x80171717);
  static const Color _noteFieldBorder = Color(0x3301110A);
  static const Color _cancelBgColor = Color(0x33000000);
  static const Color _hintColor = Color(0x33FFFFFF);
  static const Color _subtitleColor = Color(0xFFD9D9D9);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
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
          width: _cardWidth,
          height: _cardHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _buildCard(),
              Positioned(top: 10, right: 10, child: _buildCloseButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: _cardWidth,
      height: _cardHeight,
      decoration: BoxDecoration(
        color: AppColors.color004216,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 30),
            blurRadius: 15,
            color: Color(0x33000000),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(top: 20, left: 20, child: _buildProductImage()),
          Positioned(
            top: 32,
            left: 100,
            right: 50,
            child: Text(
              widget.dishSubtitle,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Oswald',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                height: 22 / 16,
                letterSpacing: 0,
                color: _subtitleColor,
              ),
            ),
          ),
          Positioned(
            top: 64,
            left: 100,
            right: 50,
            child: AppText(
              text: widget.dishTitle,
              textAlign : TextAlign.left,
              appTextStyle: AppTextStyle.oswaldSemiBold20Gold,
              customFontSize: 22,
              customColor: const Color(0xFFD09843),
              maxLines: 1,
              applyTextTransform: false,
            ),
          ),
          Positioned(
            top: 105,
            left: 20,
            right: 20,
            child: _buildNotesField(),
          ),
          Positioned(
            top: 210,
            right: 20,
            child: _buildButtonRow(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return SizedBox(
      width: _imageSize,
      height: _imageSize,
      child: ClipOval(
        child: (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: widget.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _imagePlaceholder(),
                errorWidget: (_, __, ___) => _imagePlaceholder(),
              )
            : _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePlaceholder() {
    final letter = widget.dishTitle.isNotEmpty
        ? widget.dishTitle.characters.first.toUpperCase()
        : '?';
    return Container(
      color: AppColors.color01110A,
      alignment: Alignment.center,
      child: AppText(
        text: letter,
        appTextStyle: AppTextStyle.oswaldSemiBold20Gold,
        applyTextTransform: false,
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: _noteFieldFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _noteFieldBorder, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
      child: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        cursorColor: AppColors.colorFFFFFF,
        style: const TextStyle(
          fontFamily: 'Oswald',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.2,
          color: AppColors.colorFFFFFF,
        ),
        decoration: const InputDecoration.collapsed(
          hintText: 'Your order notes…',
          hintStyle: TextStyle(
            fontFamily: 'Oswald',
            fontWeight: FontWeight.w400,
            fontSize: 13,
            color: _hintColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.of(context).pop(),
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
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _pillButton(
          label: 'Cancel',
          backgroundColor: _cancelBgColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 10),
        _pillButton(
          label: 'Add Note',
          backgroundColor: AppColors.colorBD7D28,
          onPressed: () =>
              Navigator.of(context).pop(_controller.text.trim()),
        ),
      ],
    );
  }

  Widget _pillButton({
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 140,
      height: 46,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(23),
        child: InkWell(
          borderRadius: BorderRadius.circular(23),
          onTap: onPressed,
          child: Center(
            child: AppText(
              text: label,
              appTextStyle: AppTextStyle.oswaldMedium18White,
              customFontSize: 16,
              applyTextTransform: false,
            ),
          ),
        ),
      ),
    );
  }
}
