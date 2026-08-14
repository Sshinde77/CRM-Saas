import 'package:image_picker/image_picker.dart';

import 'category_image_picker_types.dart';

Future<PickedCategoryImage?> pickCategoryImageImpl() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
  );
  if (picked == null) return null;
  return PickedCategoryImage(
    bytes: await picked.readAsBytes(),
    name: picked.name,
  );
}
