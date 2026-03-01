import 'dart:convert';
import 'dart:io';

void writeDebugLog(String path, Map<String, dynamic> payload) {
  try {
    File(path).writeAsStringSync(
      '${jsonEncode(payload)}\n',
      mode: FileMode.append,
    );
  } catch (_) {}
}
