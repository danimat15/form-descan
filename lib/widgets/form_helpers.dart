import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormLabel extends StatelessWidget {
  final String text;
  final String? helperText;
  const FormLabel(this.text, {super.key, this.helperText});

  @override
  Widget build(BuildContext context) {
    final bool hasAsterisk = text.endsWith(' *');
    final String cleanText = hasAsterisk ? text.substring(0, text.length - 2) : text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: cleanText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF574237), // matching our theme's onSurfaceVariant
                fontFamily: 'Inter',
              ),
              children: [
                if (hasAsterisk)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          if (helperText != null && helperText!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              helperText!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.red, // red color for notes
              ),
              softWrap: true,
            ),
          ],
        ],
      ),
    );
  }
}

InputDecoration getFormDecoration({
  String? value,
  bool isAutofill = false,
  String? prefixText,
  String? suffixText,
  String? hintText,
}) {
  final bool isFilled = value != null && value.trim().isNotEmpty && value != '0' && value != '0.0' && value != 'Not set' && value != 'Not Set';
  
  Color fill;
  if (isAutofill) {
    fill = const Color(0xFFF5F5F5); // Light gray for autofilled/read-only (grey.shade100)
  } else if (isFilled) {
    fill = const Color(0xFFE8F5E9); // Light green for filled/completed (green.shade50)
  } else {
    fill = Colors.white; // Default white
  }

  return InputDecoration(
    prefixText: prefixText,
    suffixText: suffixText,
    hintText: hintText,
    fillColor: fill,
    filled: true,
  );
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Only allow digits, dots, and commas
    final regExp = RegExp(r'^[0-9.,]*$');
    if (!regExp.hasMatch(newValue.text)) {
      return oldValue;
    }

    // Ensure there is at most one comma
    final commaCount = ','.allMatches(newValue.text).length;
    if (commaCount > 1) {
      return oldValue;
    }

    // Split text into integer and decimal parts at the comma
    final parts = newValue.text.split(',');
    final String integerPartRaw = parts[0].replaceAll('.', '');
    final String decimalPartRaw = parts.length > 1 ? parts[1] : '';

    // Verify raw parts contain only digits
    if (integerPartRaw.isNotEmpty && !RegExp(r'^\d+$').hasMatch(integerPartRaw)) {
      return oldValue;
    }
    if (decimalPartRaw.isNotEmpty && !RegExp(r'^\d+$').hasMatch(decimalPartRaw)) {
      return oldValue;
    }

    // Format integer part with dots as thousands separators
    final formattedInteger = _formatDots(integerPartRaw);
    final formattedText = parts.length > 1 ? '$formattedInteger,$decimalPartRaw' : formattedInteger;

    // Calculate cursor position
    int originalDigitsBeforeCursor = 0;
    int commaBeforeCursor = 0;
    for (int i = 0; i < newValue.selection.end && i < newValue.text.length; i++) {
      final char = newValue.text[i];
      if (char == ',') {
        commaBeforeCursor++;
      } else if (char != '.') {
        originalDigitsBeforeCursor++;
      }
    }

    int newSelectionIndex = 0;
    int digitCount = 0;
    int commaCountFound = 0;
    while (newSelectionIndex < formattedText.length) {
      final char = formattedText[newSelectionIndex];
      if (char == ',') {
        if (commaBeforeCursor > 0 && commaCountFound < commaBeforeCursor) {
          commaCountFound++;
        } else {
          break;
        }
      } else if (char != '.') {
        if (digitCount < originalDigitsBeforeCursor) {
          digitCount++;
        } else {
          break;
        }
      }
      newSelectionIndex++;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }

  String _formatDots(String digits) {
    if (digits.isEmpty) return '';
    final buffer = StringBuffer();
    final len = digits.length;
    for (int i = 0; i < len; i++) {
      buffer.write(digits[i]);
      final remaining = len - 1 - i;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }
}

String formatThousands(String? text) {
  if (text == null || text.isEmpty) return '';
  final clean = text.replaceAll('.', '');
  
  final parts = clean.split(',');
  final String integerPart = parts[0];
  final String decimalPart = parts.length > 1 ? parts[1] : '';

  final buffer = StringBuffer();
  final len = integerPart.length;
  for (int i = 0; i < len; i++) {
    buffer.write(integerPart[i]);
    final remaining = len - 1 - i;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write('.');
    }
  }
  
  if (parts.length > 1) {
    buffer.write(',');
    buffer.write(decimalPart);
  }
  return buffer.toString();
}

double parseIndonesianDouble(String? text) {
  if (text == null || text.isEmpty) return 0.0;
  final cleaned = text.replaceAll('.', '').replaceAll(',', '.');
  return double.tryParse(cleaned) ?? 0.0;
}

String formatDouble(double? val) {
  if (val == null) return '';
  if (val % 1 == 0) {
    return formatThousands(val.toStringAsFixed(0));
  } else {
    return formatThousands(val.toString().replaceAll('.', ','));
  }
}
