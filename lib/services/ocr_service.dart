import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Service for extracting text from receipt images using OCR
class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Extract expense data from receipt image
  Future<Map<String, dynamic>> extractReceiptData(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Extract data from recognized text
      final extractedData = _parseReceiptText(recognizedText.text);

      return extractedData;
    } catch (e) {
      if (kDebugMode) {
        print('OCR Error: $e');
      }
      return {'amount': null, 'merchant': null, 'date': null, 'rawText': ''};
    }
  }

  /// Parse recognized text to extract amount, merchant, and date
  Map<String, dynamic> _parseReceiptText(String text) {
    double? amount;
    String? merchant;
    DateTime? date;

    final lines = text.split('\n');

    // Extract amount (look for currency symbols and numbers)
    final amountRegex = RegExp(r'[\$£€¥]?\s*(\d+[.,]\d{2})');
    for (final line in lines) {
      final match = amountRegex.firstMatch(line);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '.');
        amount = double.tryParse(amountStr ?? '');
        if (amount != null && amount > 0) {
          break;
        }
      }
    }

    // Extract merchant name (usually first non-empty line)
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty &&
          trimmed.length > 2 &&
          !_isNumericLine(trimmed)) {
        merchant = trimmed;
        break;
      }
    }

    // Extract date (look for common date patterns)
    final dateRegex = RegExp(
      r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})|(\d{4}[/-]\d{1,2}[/-]\d{1,2})',
    );
    for (final line in lines) {
      final match = dateRegex.firstMatch(line);
      if (match != null) {
        date = _parseDate(match.group(0) ?? '');
        if (date != null) {
          break;
        }
      }
    }

    return {
      'amount': amount,
      'merchant': merchant,
      'date': date,
      'rawText': text,
    };
  }

  /// Check if line is mostly numeric
  bool _isNumericLine(String line) {
    final numericChars = line.replaceAll(RegExp(r'[^0-9]'), '');
    return numericChars.length > line.length * 0.5;
  }

  /// Parse date string to DateTime
  DateTime? _parseDate(String dateStr) {
    try {
      // Try different date formats
      final formats = [
        RegExp(
          r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})',
        ), // DD/MM/YYYY or MM/DD/YYYY
        RegExp(r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})'), // YYYY/MM/DD
        RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2})'), // DD/MM/YY or MM/DD/YY
      ];

      for (final format in formats) {
        final match = format.firstMatch(dateStr);
        if (match != null) {
          final part1 = int.tryParse(match.group(1) ?? '');
          final part2 = int.tryParse(match.group(2) ?? '');
          final part3 = int.tryParse(match.group(3) ?? '');

          if (part1 != null && part2 != null && part3 != null) {
            // Determine format and create DateTime
            if (part3 > 31) {
              // Year is in part3
              final year = part3 < 100 ? 2000 + part3 : part3;
              return DateTime(year, part2, part1);
            } else if (part1 > 31) {
              // Year is in part1 (YYYY/MM/DD)
              return DateTime(part1, part2, part3);
            } else {
              // Assume MM/DD/YYYY format
              final year = part3 < 100 ? 2000 + part3 : part3;
              return DateTime(year, part1, part2);
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Date parsing error: $e');
      }
    }
    return null;
  }

  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
  }
}
