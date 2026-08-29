import 'dart:typed_data';

class PickedCategoryImage {
  final Uint8List bytes;
  final String name;

  const PickedCategoryImage({required this.bytes, required this.name});
}
