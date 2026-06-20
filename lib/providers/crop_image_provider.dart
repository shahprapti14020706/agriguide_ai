import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../core/config/firebase_runtime.dart';
import '../core/constants/storage_paths.dart';
import '../models/crop_image_model.dart';
import '../models/crop_model.dart';
import '../repositories/crop_image_repository.dart';
import '../services/firebase_storage_service.dart';
import '../services/local_storage_service.dart';
import 'base_provider.dart';

class CropImageProvider extends BaseProvider {
  CropImageProvider({
    required CropImageRepository cropImageRepository,
    required FirebaseStorageService storageService,
    required LocalStorageService localStorageService,
  })  : _cropImageRepository = cropImageRepository,
        _storageService = storageService,
        _localStorageService = localStorageService;

  static String _localKey(String userId) => 'crop_images_$userId';

  final CropImageRepository _cropImageRepository;
  final FirebaseStorageService _storageService;
  final LocalStorageService _localStorageService;
  final List<CropImageModel> _images = [];

  List<CropImageModel> get images => List.unmodifiable(_images);

  Future<void> loadImages(String userId, {String? cropId}) async {
    setLoading();
    try {
      final loaded = FirebaseRuntime.isAvailable
          ? await _cropImageRepository.getImages(userId, cropId: cropId)
          : _readLocal(userId);
      _images
        ..clear()
        ..addAll(
          cropId == null
              ? loaded
              : loaded.where((image) => image.cropId == cropId),
        );
      _images.isEmpty ? setEmpty() : setSuccess();
    } catch (error) {
      setFailure(error);
    }
  }

  Future<void> uploadImage({
    required CropModel crop,
    required XFile pickedImage,
    String? caption,
  }) async {
    await runGuarded(() async {
      final now = DateTime.now();
      final id = 'crop_image_${now.microsecondsSinceEpoch}';
      final storagePath =
          '${StoragePaths.cropImageUploads(crop.userId)}/$id.jpg';
      final metadata = SettableMetadata(
        contentType: pickedImage.mimeType ?? 'image/jpeg',
      );
      final imageUrl = await _resolveImageUrl(
        image: pickedImage,
        storagePath: storagePath,
        metadata: metadata,
      );
      var image = CropImageModel(
        id: id,
        userId: crop.userId,
        cropId: crop.id,
        cropName: crop.cropName,
        imageUrl: imageUrl,
        storagePath: storagePath,
        caption: caption,
        createdAt: now,
      );
      if (FirebaseRuntime.isAvailable) {
        final savedId = await _cropImageRepository.saveImage(image);
        image = CropImageModel.fromMap({...image.toMap(), 'id': savedId});
      }
      _images.insert(0, image);
      await _saveLocal(crop.userId);
    });
  }

  Future<String> _resolveImageUrl({
    required XFile image,
    required String storagePath,
    required SettableMetadata metadata,
  }) async {
    if (FirebaseRuntime.isAvailable) {
      if (kIsWeb) {
        return _storageService.uploadData(
          storagePath: storagePath,
          data: await image.readAsBytes(),
          metadata: metadata,
        );
      }
      return _storageService.uploadFile(
        storagePath: storagePath,
        file: File(image.path),
        metadata: metadata,
      );
    }

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      final mimeType = image.mimeType ?? 'image/jpeg';
      return 'data:$mimeType;base64,${base64Encode(bytes)}';
    }
    return image.path;
  }

  List<CropImageModel> _readLocal(String userId) {
    final raw = _localStorageService.getString(_localKey(userId));
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .whereType<Map>()
        .map((item) => CropImageModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> _saveLocal(String userId) {
    final data = _images.map((item) => item.toJson()).toList();
    return _localStorageService.setString(_localKey(userId), jsonEncode(data));
  }
}
