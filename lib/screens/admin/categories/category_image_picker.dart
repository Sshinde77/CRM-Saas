import 'category_image_picker_stub.dart'
    if (dart.library.html) 'category_image_picker_web.dart';
import 'category_image_picker_types.dart';

export 'category_image_picker_stub.dart'
    if (dart.library.html) 'category_image_picker_web.dart';

Future<PickedCategoryImage?> pickCategoryImage() => pickCategoryImageImpl();
