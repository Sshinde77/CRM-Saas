import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/app_colors.dart';

Future<XFile?> showDeliveryImageSourcePicker({
  required BuildContext context,
  required ImagePicker picker,
  required String title,
  double? maxWidth = 1600,
  double? maxHeight,
  int imageQuality = 82,
}) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD7DCE4),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.deliveryInk,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            minTileHeight: 52,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: const Icon(Icons.camera_alt_outlined, size: 24),
            title: const Text(
              'Take a photo',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
          ),
          ListTile(
            minTileHeight: 52,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: const Icon(Icons.photo_library_outlined, size: 24),
            title: const Text(
              'Choose from files',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null || !context.mounted) return null;

  if (source == ImageSource.camera) {
    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to take a photo.'),
          ),
        );
      }
      return null;
    }
  }

  return picker.pickImage(
    source: source,
    imageQuality: imageQuality,
    maxWidth: maxWidth,
    maxHeight: maxHeight,
  );
}

class DeliveryImageUploadField extends StatelessWidget {
  const DeliveryImageUploadField({
    super.key,
    required this.bytes,
    required this.onTap,
    this.aspectRatio = 1.35,
    this.enabled = true,
  });

  final Uint8List? bytes;
  final VoidCallback onTap;
  final double aspectRatio;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Material(
        color: const Color(0xFFF2F3F6),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFCDD3DC)),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: bytes == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 32,
                      color: AppColors.deliveryGreen,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Camera or file',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(bytes!, fit: BoxFit.contain),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.58),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
