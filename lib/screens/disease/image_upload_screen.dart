import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../app/routes/route_names.dart';
import '../../models/crop_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/disease_detection_provider.dart';
import '../../widgets/disease/uploaded_image_preview.dart';

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  State<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  final _picker = ImagePicker();
  String? _selectedCropId;
  String _plantPart = 'Leaf';
  bool _requestedCropLoad = false;

  static const _plantParts = [
    'Leaf',
    'Stem',
    'Fruit',
    'Flower',
    'Whole Plant',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_requestedCropLoad) {
      return;
    }

    final user = context.read<AuthProvider>().currentUser;
    final cropProvider = context.read<CropProvider>();
    if (user != null && cropProvider.crops.isEmpty && !cropProvider.isLoading) {
      _requestedCropLoad = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => cropProvider.loadCrops(user.id),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (!mounted || image == null) {
      return;
    }

    await context.read<DiseaseDetectionProvider>().selectImage(image);
  }

  Future<void> _analyze() async {
    final user = context.read<AuthProvider>().currentUser;
    final cropProvider = context.read<CropProvider>();
    final diseaseProvider = context.read<DiseaseDetectionProvider>();

    if (user == null) {
      return;
    }

    final selectedCropId = _selectedCropId;
    if (selectedCropId == null || selectedCropId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select crop')),
      );
      return;
    }

    if (_plantPart.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select plant part')),
      );
      return;
    }

    final selectedImage = diseaseProvider.selectedImage;
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload image')),
      );
      return;
    }

    final crop = cropProvider.cropById(selectedCropId);
    if (crop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select crop')),
      );
      return;
    }

    final report = await diseaseProvider.analyzeAndSave(
      userId: user.id,
      crop: crop,
      image: selectedImage,
      plantPart: _plantPart,
    );

    if (!mounted) {
      return;
    }

    if (diseaseProvider.hasError || report == null) {
      final message =
          diseaseProvider.failure?.message ?? 'Disease analysis failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          diseaseProvider.successMessage ?? 'Disease analysis completed',
        ),
      ),
    );
    Navigator.of(context).pushReplacementNamed(
      RouteNames.diseaseReport,
      arguments: report.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Plant Image'),
      ),
      body: SafeArea(
        child: user == null
            ? const Center(
                child: Text('Please sign in to analyze crop diseases.'),
              )
            : Consumer2<CropProvider, DiseaseDetectionProvider>(
                builder: (context, cropProvider, diseaseProvider, _) {
                  _syncSelectedCrop(cropProvider.crops);
                  final canAnalyze = !diseaseProvider.isLoading;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (diseaseProvider.hasError &&
                                diseaseProvider.failure != null) ...[
                              _DiseaseError(
                                message: diseaseProvider.failure!.message,
                              ),
                              const SizedBox(height: 16),
                            ],
                            _CropSelector(
                              crops: cropProvider.crops,
                              selectedCropId: _selectedCropId,
                              onChanged: (value) {
                                setState(() => _selectedCropId = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _plantPart,
                              decoration: const InputDecoration(
                                labelText: 'Plant Part',
                                prefixIcon: Icon(Icons.local_florist_outlined),
                              ),
                              items: _plantParts
                                  .map(
                                    (part) => DropdownMenuItem(
                                      value: part,
                                      child: Text(part),
                                    ),
                                  )
                                  .toList(growable: false),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _plantPart = value);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            if (diseaseProvider.selectedImage == null)
                              _ImagePickerActions(
                                onCamera: () => _pickImage(ImageSource.camera),
                                onGallery: () =>
                                    _pickImage(ImageSource.gallery),
                              )
                            else
                              UploadedImagePreview(
                                image: diseaseProvider.selectedImage!,
                                imageBytes: diseaseProvider.selectedImageBytes,
                                onRemove: () {
                                  diseaseProvider.clearSelectedImage();
                                },
                              ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: canAnalyze ? _analyze : null,
                              icon: diseaseProvider.isLoading
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.biotech_outlined),
                              label: const Text('Analyze Disease'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _syncSelectedCrop(List<CropModel> crops) {
    final selectedCropId = _selectedCropId;
    final selectedCropExists = selectedCropId != null &&
        crops.any((crop) => crop.id == selectedCropId);

    if (selectedCropExists) {
      return;
    }

    final nextCropId = crops.length == 1 ? crops.first.id : null;
    if (selectedCropId == nextCropId) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _selectedCropId != nextCropId) {
        setState(() => _selectedCropId = nextCropId);
      }
    });
  }
}

class _CropSelector extends StatelessWidget {
  const _CropSelector({
    required this.crops,
    required this.selectedCropId,
    required this.onChanged,
  });

  final List<CropModel> crops;
  final String? selectedCropId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (crops.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Add a crop before creating a disease report.'),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      key: ValueKey(selectedCropId ?? 'no_crop_selected'),
      initialValue: selectedCropId,
      decoration: const InputDecoration(
        labelText: 'Select Crop',
        prefixIcon: Icon(Icons.grass_outlined),
      ),
      items: crops
          .map(
            (crop) => DropdownMenuItem(
              value: crop.id,
              child: Text('${crop.cropName} - ${crop.variety}'),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}

class _ImagePickerActions extends StatelessWidget {
  const _ImagePickerActions({
    required this.onCamera,
    required this.onGallery,
  });

  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Capture a clear plant image or select one from gallery.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onCamera,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera'),
                ),
                OutlinedButton.icon(
                  onPressed: onGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DiseaseError extends StatelessWidget {
  const _DiseaseError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
    );
  }
}
