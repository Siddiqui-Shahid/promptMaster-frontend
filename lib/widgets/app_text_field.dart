import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.helperText,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.onFieldSubmitted,
    this.focusNode,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator;
  final String? helperText;
  final String? hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines > 1;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      validator: validator,
      keyboardType: keyboardType ?? (isMultiline ? TextInputType.multiline : TextInputType.text),
      textInputAction: textInputAction ?? (isMultiline ? TextInputAction.newline : TextInputAction.next),
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 22) : null,
      ),
    );
  }
}
