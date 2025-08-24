import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TextFormField, TextEditingController, Key, InputDecoration, FocusNode, AutovalidateMode, TextAlignVertical;
import 'package:flutter/services.dart';
import 'package:flutter_core_module/enums.dart';

extension InputTypeField on InputType
{
  List<TextInputFormatter> get _formatters {
    switch (this) {
      case InputType.email:
        return [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
        ];
      case InputType.phone:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(20),
        ];
      case InputType.username:
        return [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
        ];
      case InputType.number:
        return [FilteringTextInputFormatter.digitsOnly];

        case InputType.currency:
        return [
          FilteringTextInputFormatter.digitsOnly,
        ];
        case InputType.panNumber:
        return [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          LengthLimitingTextInputFormatter(10),
          PanCardInputFormatter()
        ];
        case InputType.aadhaarNumber:
        return [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          LengthLimitingTextInputFormatter(12),
        ];
      default:
        return [];
    }
  }

  TextInputType get _keyboard {
    switch (this) {
      case InputType.email:
        return TextInputType.emailAddress;
      case InputType.phone:
        return TextInputType.phone;
      case InputType.username:
        return TextInputType.text;
      case InputType.number:
        return TextInputType.number;
      case InputType.currency:
        return const TextInputType.numberWithOptions(decimal: true,signed: true);
      case InputType.text:
        return TextInputType.text;
      case InputType.panNumber:
        return TextInputType.text;
      case InputType.aadhaarNumber:
        return TextInputType.number;
      }
  }

  TextFormField field({
    required TextEditingController controller, Key? key,
    String? Function(String?)? validator,
    bool obscureText = false,
    int? maxLines = 1,
    bool readOnly=false,
    bool enabled=true,
    Function(String)? onChange,
    VoidCallback? onTap,
    TextStyle? style,
    List<TextInputFormatter> formatters=const [],
    AutovalidateMode? autoValidateMode,
    InputDecoration? decoration,
  }) {

    return TextFormField(
      key: key,
      controller: controller,
      inputFormatters: [..._formatters,...formatters],
      keyboardType:_keyboard,
      validator: validator,
      obscureText: obscureText,
      maxLines: maxLines,
      readOnly: readOnly,
      enabled: enabled,
      onChanged: onChange,
      onTap: onTap,
      autovalidateMode: autoValidateMode,
      canRequestFocus:enabled && readOnly,
      textAlignVertical: TextAlignVertical.center,
      textAlign: TextAlign.center,
      decoration: decoration,
      style: style,
    );
  }
}
extension TextFormFieldExtensions on TextFormField {
  TextFormField withDecoration({
    InputDecoration? decoration,
  }) {
    return TextFormField(
      decoration: decoration,
    );
  }
  TextFormField withFormatters({
    required List<TextInputFormatter> formatters,
  }) {
    return TextFormField(
      inputFormatters: formatters,
    );
  }TextFormField withKeyboardType({
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
    );
  }
}

class PanCardInputFormatter extends TextInputFormatter {
  final RegExp _regExp = RegExp(r'^[A-Z]{0,5}[0-9]{0,4}[A-Z]{0,1}$');
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.toUpperCase(); // auto-uppercase

    if (_regExp.hasMatch(text)) {
      return newValue.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    return oldValue;
  }
}

