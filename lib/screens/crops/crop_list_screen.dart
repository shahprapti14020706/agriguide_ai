import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../widgets/crop/active_crop_card.dart';

class CropListScreen extends StatefulWidget {
  const CropListScreen({super.key});

  @override
  State<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends State<CropListScreen> {
  bool _requestedLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_requestedLoad) {
      return;
    }

    _requestedLoad = true;
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<CropProvider>().loadCrops(user.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crops'),
      ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed(
                RouteNames.addCrop,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Crop'),
            ),
      body: SafeArea(
        child: user == null
            ? const Center(child: Text('Please sign in to manage crops.'))
            : Consumer<CropProvider>(
                builder: (context, cropProvider, _) {
                  if (cropProvider.isLoading && cropProvider.crops.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (cropProvider.hasError && cropProvider.failure != null) {
                    return _CropStateMessage(
                      icon: Icons.error_outline,
                      message: cropProvider.failure!.message,
                    );
                  }

                  if (cropProvider.crops.isEmpty) {
                    return const _CropStateMessage(
                      icon: Icons.grass_outlined,
                      message: 'No crops added yet. Add your first crop.',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => cropProvider.loadCrops(user.id),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: cropProvider.crops.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final crop = cropProvider.crops[index];
                        return ActiveCropCard(
                          crop: crop,
                          stageEstimate: cropProvider.estimateStage(crop),
                          onTap: () => Navigator.of(context).pushNamed(
                            RouteNames.cropDetails,
                            arguments: crop.id,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _CropStateMessage extends StatelessWidget {
  const _CropStateMessage({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
