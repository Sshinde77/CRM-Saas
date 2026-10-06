import 'product_image_url.dart';

/// Reads only customer photo fields, so order/product images are never used.
String? customerPhotoUrlFromJson(Map<String, dynamic> json) {
  for (final key in const [
    'customer_profile_photo',
    'customer_profile_photo_url',
    'customer_profile_image',
    'customer_profile_image_url',
    'customer_photo',
    'customer_photo_url',
    'profile_photo',
    'profile_photo_url',
    'profile_image',
    'profile_image_url',
    'profile_image_id',
    'profilePhoto',
    'profilePhotoUrl',
    'photo_url',
    'photoUrl',
    'avatar_url',
    'avatar',
  ]) {
    final value = json[key];
    final raw = value is Map
        ? value['url'] ??
              value['file_url'] ??
              value['download_url'] ??
              value['file_id'] ??
              value['id']
        : value;
    if (raw is String && raw.trim().isNotEmpty) {
      return normalizeProductImageUrl(raw);
    }
  }
  for (final key in const [
    'customer',
    'customer_details',
    'customerDetails',
    'basic_information',
  ]) {
    final nested = json[key];
    if (nested is Map<String, dynamic>) {
      final photo = customerPhotoUrlFromJson(nested);
      if (photo != null) return photo;
    }
  }
  return null;
}
