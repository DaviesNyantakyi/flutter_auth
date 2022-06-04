import 'package:flutter/material.dart';
import 'package:flutter_auth/constant.dart';

Future<dynamic> showMyBottomSheet({
  required BuildContext context,
  Widget? child,
  bool? isDismissible = true,
  bool isScrollControlled = true,
  bool enableDrag = true,
  double? height = kBottomSheetHeight,
  double? fullScreenHeight = 0.9,
  EdgeInsetsGeometry padding = const EdgeInsets.all(kBodyPadding),
}) async {
  return await showModalBottomSheet<dynamic>(
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible!,
    enableDrag: enableDrag,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
    ),
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: fullScreenHeight,
        child: Container(
          height: height,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(kRadius),
              topRight: Radius.circular(kRadius),
            ),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      );
    },
  );
}
