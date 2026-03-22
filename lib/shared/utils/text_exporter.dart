import 'package:flutter/services.dart';

class TextExporter {
  static Future<void> copyToClipboard(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
  }
}
