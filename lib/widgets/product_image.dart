import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/product_image_url.dart';

/// Shared widget that shows a product image (network or base64), with a
/// colored-icon fallback when no image is available.
class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double borderRadius;

  /// Used to pick a consistent fallback background color; pass the product name.
  final String? seed;

  const ProductImage({
    super.key,
    this.imageUrl,
    this.size = 48,
    this.borderRadius = 10,
    this.seed,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    final imageBytes = url.isNotEmpty ? productImageBytes(url) : null;

    Widget child;
    if (imageBytes != null) {
      child = Image.memory(
        imageBytes,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => _fallback(url),
      );
    } else if (url.isNotEmpty) {
      child = Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => _fallback(url),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _fallback(url),
      );
    } else {
      child = _fallback(url);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _fallback(String url) {
    const colors = [
      Color(0xFFE0F2FE),
      Color(0xFFDCFCE7),
      Color(0xFFFFEDD5),
      Color(0xFFF3E8FF),
      Color(0xFFFCE7F3),
    ];
    final colorSeed = (seed ?? url).isNotEmpty ? (seed ?? url) : 'product';
    final color = colors[colorSeed.hashCode.abs() % colors.length];
    return Container(
      color: color,
      child: Icon(
        Icons.inventory_2_outlined,
        color: AppColors.textSecondary,
        size: size * 0.46,
      ),
    );
  }
}
