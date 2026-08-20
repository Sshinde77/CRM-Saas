// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:async';
import 'dart:typed_data';

import 'category_image_picker_types.dart';

Future<PickedCategoryImage?> pickCategoryImageImpl() async {
  final completer = Completer<PickedCategoryImage?>();
  final input = html.FileUploadInputElement()..accept = 'image/*';

  input.onChange.listen((_) async {
    final files = input.files;
    final file = (files != null && files.isNotEmpty) ? files.first : null;
    if (file == null) {
      if (!completer.isCompleted) completer.complete(null);
      return;
    }

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    final result = PickedCategoryImage(
      bytes: (reader.result as ByteBuffer).asUint8List(),
      name: file.name,
    );
    if (!completer.isCompleted) completer.complete(result);
  });

  input.click();
  return completer.future;
}
