import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final String labelText;
  final IconData icondata;
  final FormFieldValidator? validator;
  final TextEditingController controller;
  final bool isAuthField;
  final TextInputType? keyboardType;
  final bool? isEnabled;
  final bool hasInitValue;
  final String? initValue;
  final bool? isPassword;
  const InputField({
    super.key,
    this.isEnabled,
    required this.isAuthField,
    required this.keyboardType,
    required this.labelText,
    required this.icondata,
    required this.controller,
    this.validator,
    required this.hasInitValue,
    required this.isPassword,
    this.initValue,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 300,
      height: 50,
      child: TextFormField(
        obscureText: widget.isPassword!,
        initialValue: widget.hasInitValue ? widget.initValue : null,
        enabled: widget.isEnabled,
        keyboardType: widget.keyboardType,
        validator: widget.isAuthField ? widget.validator : null,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
            borderRadius: BorderRadius.circular(8),
          ),
          labelText: widget.labelText,
          hintText: "Enter your ${widget.labelText}",
          prefixIcon: Icon(widget.icondata),
        ),
        controller: widget.controller,
      ),
    );
  }
}
