import 'dart:convert';
import 'dart:typed_data';

import '../constants/api_constants.dart';

String? productImageUrlFromJson(Map<String, dynamic> json) {
  final direct = _assetText(json, const [
    'product_image_url',
    'productImageUrl',
    'image_url',
    'imageUrl',
    'thumbnail_url',
    'thumbnailUrl',
    'photo_url',
    'photoUrl',
    'image',
    'product_image',
    'productImage',
    'thumbnail',
    'photo',
    'picture',
    'cover_image',
    'coverImage',
  ]);
  final normalized = normalizeProductImageUrl(direct);
  if (normalized != null) return normalized;

  for (final key in const [
    'product',
    'product_details',
    'productDetails',
    'item',
    'inventory_item',
    'inventoryItem',
  ]) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      final nested = productImageUrlFromJson(value);
      if (nested != null) return nested;
    } else if (value is Map) {
      final nested = productImageUrlFromJson(Map<String, dynamic>.from(value));
      if (nested != null) return nested;
    }
  }

  final fileId = _assetText(json, const [
    'product_image_id',
    'productImageId',
    'image_file_id',
    'imageFileId',
    'file_id',
    'fileId',
  ]);
  if (fileId == null || fileId.isEmpty) return null;

  return Uri.parse(
    ApiConstants.baseUrl,
  ).resolve(ApiEndpoints.fileDetail(fileId)).toString();
}

String? normalizeProductImageUrl(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return null;
  if (text.startsWith('data:image/')) return text;
  final uri = Uri.tryParse(text);
  if (uri != null && uri.hasScheme) return text;
  if (text.startsWith('/')) {
    return Uri.parse(ApiConstants.baseUrl).resolve(text).toString();
  }
  if (RegExp(r'^[0-9a-fA-F-]{20,}$').hasMatch(text)) {
    return Uri.parse(
      ApiConstants.baseUrl,
    ).resolve(ApiEndpoints.fileDetail(text)).toString();
  }
  return Uri.parse(ApiConstants.baseUrl).resolve('/$text').toString();
}

Uint8List? productImageBytes(String? value) {
  final text = value?.trim();
  if (text == null || !text.startsWith('data:image/')) return null;
  final commaIndex = text.indexOf(',');
  if (commaIndex == -1 || commaIndex == text.length - 1) return null;
  try {
    return base64Decode(text.substring(commaIndex + 1));
  } catch (_) {
    return null;
  }
}

String? _assetText(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    final text = _assetValueText(value);
    if (text != null && text.isNotEmpty) return text;
  }
  return null;
}

String? _assetValueText(Object? value) {
  if (value == null) return null;
  if (value is List && value.isNotEmpty) {
    return _assetValueText(value.first);
  }
  if (value is Map<String, dynamic>) {
    return _assetText(value, const [
      'url',
      'download_url',
      'downloadUrl',
      'file_url',
      'fileUrl',
      'path',
      'file_id',
      'fileId',
      'id',
    ]);
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
