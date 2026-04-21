import 'package:flutter/material.dart';
import 'package:hookahhabibi/Screen/Menu/Service/HHMenuLegendModel.dart';
import 'package:hookahhabibi/utils/AppText.dart';
import 'package:hookahhabibi/utils/AppTextStyle.dart';
import 'package:hookahhabibi/utils/app_colors.dart';
import 'package:hookahhabibi/utils/app_dimens.dart';


class HHMenuLegend extends StatelessWidget {
  final List<HHMenuLegendModel> legends;

  const HHMenuLegend({
    Key? key,
    required this.legends,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.margin16,
        vertical: Dimens.margin12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: legends.map((legend) {
          return Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (legend.iconString != null && legend.iconString!.isNotEmpty) ...[
                  Container(
                    width: Dimens.margin24,
                    height: Dimens.margin24,
                    child: Image.asset(
                      legend.iconString!,
                      width: Dimens.margin24,
                      height: Dimens.margin24,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.thumb_up,
                          color: AppColors.color00541A,
                          size: Dimens.margin20,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                SizedBox(
                  height: 21,
                  child: AppText(text: legend.title, appTextStyle: AppTextStyle.oswaldRegular14UppercaseLight),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}