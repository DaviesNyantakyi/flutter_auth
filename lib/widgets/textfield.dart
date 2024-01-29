import 'package:flutter/material.dart';
import 'package:flutter_auth/constant.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final String? initialValue;

  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final bool? obscureText;
  final bool readOnly;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final VoidCallback? onTap;
  final int? maxLines;
  final int? maxLength;
  final Function(String)? onSubmitted;
  final Color? fillColor;
  final InputBorder? focusedBorder;
  final TextStyle? style;
  final TextEditingController? controller;
  final AutovalidateMode? validateMode;

  const CustomTextFormField({
    super.key,
    this.hintText,
    this.initialValue,
    this.maxLines,
    this.keyboardType,
    this.controller,
    this.onSubmitted,
    this.style,
    this.onTap,
    this.maxLength,
    this.focusedBorder,
    this.fillColor,
    this.prefixIcon,
    this.onChanged,
    this.obscureText = false,
    this.validator,
    this.textInputAction,
    this.suffixIcon,
    this.readOnly = false,
    this.validateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: maxLength,
      controller: controller,
      validator: validator,
      initialValue: initialValue,
      readOnly: readOnly,
      keyboardType: keyboardType,
      obscureText: obscureText!,
      textInputAction: textInputAction,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        errorMaxLines: 2,
        hintText: hintText,
        fillColor: fillColor ?? Colors.grey.shade200,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadius),
          borderSide: const BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        focusedBorder: focusedBorder,
      ),
      autovalidateMode: validateMode,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
    );
  }
}
