import 'dart:convert';
import 'package:universal_html/html.dart' as html;

Future<void> saveFile(String fileName, String content) async {
  // Web: Trigger browser download
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
