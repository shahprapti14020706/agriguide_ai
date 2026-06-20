import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadedImagePreview extends StatelessWidget {
  const UploadedImagePreview({
    required this.image,
    this.imageBytes,
    this.onRemove,
    super.key,
  });

  final XFile image;
  final Uint8List? imageBytes;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: _PreviewImage(image: image, imageBytes: imageBytes),
          ),
          if (onRemove != null)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filledTonal(
                onPressed: onRemove,
                icon: const Icon(Icons.close),
                tooltip: 'Remove image',
              ),
            ),
        ],
      ),
    );
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({
    required this.image,
    required this.imageBytes,
  });

  final XFile image;
  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    final bytes = imageBytes;
    if (kIsWeb) {
      if (bytes == null || bytes.isEmpty) {
        return const _ImageFallback(message: 'Image preview unavailable');
      }
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) =>
            const _ImageFallback(message: 'Image preview unavailable'),
      );
    }

    return Image.file(
      File(image.path),
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) =>
          const _ImageFallback(message: 'Image preview unavailable'),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: colorScheme.onSurfaceVariant,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
