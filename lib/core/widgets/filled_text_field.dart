import 'package:flutter/material.dart';

class FilledTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? helperText;
  final String? errorText;

  const FilledTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.helperText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
    );
  }
}
