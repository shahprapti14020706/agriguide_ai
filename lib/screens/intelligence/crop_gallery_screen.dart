import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/crop_image_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/business/business_cards.dart';

class CropGalleryScreen extends StatefulWidget {
  const CropGalleryScreen({super.key});

  @override
  State<CropGalleryScreen> createState() => _CropGalleryScreenState();
}

class _CropGalleryScreenState extends State<CropGalleryScreen> {
  final _picker = ImagePicker();
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) {
      return;
    }
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      await context.read<CropImageProvider>().loadImages(user.id);
    }
  }

  Future<void> _pickAndUpload() async {
    final cropProvider = context.read<CropProvider>();
    if (cropProvider.activeCrops.isEmpty) {
      return;
    }
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted || picked == null) {
      return;
    }
    await context.read<CropImageProvider>().uploadImage(
          crop: cropProvider.activeCrops.first,
          pickedImage: picked,
        );
  }

  Widget _buildCropImage(String imageUrl) {
    final source = imageUrl.trim();
    if (source.isEmpty) {
      return const _CropImagePlaceholder();
    }

    final dataImageBytes = _dataImageBytes(source);
    if (dataImageBytes != null) {
      return Image.memory(
        dataImageBytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _CropImagePlaceholder(),
      );
    }

    if (_isNetworkImage(source) || kIsWeb) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _CropImagePlaceholder(),
      );
    }

    return Image.file(
      File(source),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _CropImagePlaceholder(),
    );
  }

  bool _isNetworkImage(String source) {
    return source.startsWith('http://') ||
        source.startsWith('https://') ||
        source.startsWith('blob:');
  }

  Uint8List? _dataImageBytes(String source) {
    if (!source.startsWith('data:image')) {
      return null;
    }
    final commaIndex = source.indexOf(',');
    if (commaIndex == -1) {
      return null;
    }
    try {
      return base64Decode(source.substring(commaIndex + 1));
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final provider = context.watch<CropImageProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(strings.cropGallery)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndUpload,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(strings.uploadImage),
      ),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.images.isEmpty
                ? BusinessStateView(message: strings.noData)
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: provider.images.length,
                    itemBuilder: (context, index) {
                      final image = provider.images[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildCropImage(image.imageUrl),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                width: double.infinity,
                                color: Colors.black54,
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  image.cropName,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class _CropImagePlaceholder extends StatelessWidget {
  const _CropImagePlaceholder();

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
              Icons.crop_original,
              color: colorScheme.onSurfaceVariant,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              'Image unavailable',
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
