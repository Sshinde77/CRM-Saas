import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/product_image_url.dart';

class CustomerAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double size;

  const CustomerAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final initials = parts.isEmpty
        ? '?'
        : parts
              .take(2)
              .map((part) => part.characters.first)
              .join()
              .toUpperCase();
    final fallback = Center(
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.28,
        ),
      ),
    );
    final url = normalizeProductImageUrl(photoUrl);
    final bytes = productImageBytes(url);
    return Semantics(
      label: '$name profile photo',
      image: true,
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: AppColors.surfaceSoft,
          shape: BoxShape.circle,
        ),
        child: url == null
            ? fallback
            : bytes != null
            ? Image.memory(
                bytes,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stack) => fallback,
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stack) => fallback,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : fallback,
              ),
      ),
    );
  }
}
