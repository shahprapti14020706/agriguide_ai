import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import 'crop_form.dart';

class AddCropScreen extends StatelessWidget {
  const AddCropScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Crop'),
      ),
      body: SafeArea(
        child: user == null
            ? const Center(child: Text('Please sign in to add crops.'))
            : Consumer<CropProvider>(
                builder: (context, cropProvider, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (cropProvider.hasError &&
                                cropProvider.failure != null) ...[
                              _CropError(
                                message: cropProvider.failure!.message,
                              ),
                              const SizedBox(height: 16),
                            ],
                            CropForm(
                              userId: user.id,
                              submitLabel: 'Add crop',
                              loading: cropProvider.isLoading,
                              onSubmit: (crop) async {
                                await cropProvider.addCrop(crop);

                                if (!context.mounted || cropProvider.hasError) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      cropProvider.successMessage ??
                                          'Crop added successfully',
                                    ),
                                  ),
                                );
                                Navigator.of(context).pop();
                              },
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
}

class _CropError extends StatelessWidget {
  const _CropError({required this.message});

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
