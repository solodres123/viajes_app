import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final IconData? icon;
  final IconData? suffixIcon;
  final TextInputType? keyboard;
  final bool? censured;
  final String formProperty;
  final Map<String, String> formValues;

  const CustomInputField({
    super.key,
    this.hintText,
    this.labelText,
    this.helperText,
    this.icon,
    this.suffixIcon,
    this.keyboard,
    this.censured,
    required this.formProperty,
    required this.formValues,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: censured ?? false,
      autofocus: true,
      initialValue: '',
      textCapitalization: TextCapitalization.words,
      keyboardType: keyboard ?? TextInputType.text,
      onChanged: (value) {
        formValues[formProperty]=value;
      },
    

      validator: (value) {
        if (value == null) return 'este campo es requerido';
        return value.length < 3 ? 'minimo 3 letras' : null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        helperText: helperText,
        //hola
        //  counterText: 'mete como 3 bro',
        suffixIcon: Icon(suffixIcon),
        icon: icon == null ? null : Icon(icon),
      ),
    );
  }
}
