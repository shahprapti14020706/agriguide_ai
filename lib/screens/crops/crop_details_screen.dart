import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../widgets/crop/crop_stage_tracker.dart';

class CropDetailsScreen extends StatelessWidget {
  const CropDetailsScreen({
    required this.cropId,
    super.key,
  });

  final String cropId;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final cropProvider = context.watch<CropProvider>();
    final crop = cropProvider.cropById(cropId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Details'),
        actions: [
          if (crop != null)
            IconButton(
              tooltip: 'Edit crop',
              onPressed: () => Navigator.of(context).pushNamed(
                RouteNames.editCrop,
                arguments: crop.id,
              ),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? const Center(child: Text('Please sign in to view crop details.'))
            : crop == null
                ? const Center(child: Text('Crop record not found.'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      crop.cropName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('${crop.variety} variety'),
                                    const SizedBox(height: 16),
                                    CropStageTracker(
                                      estimate:
                                          cropProvider.estimateStage(crop),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _DetailsGrid(
                              values: {
                                'Area': '${crop.areaUnderCultivation} acres',
                                'Soil': crop.soilType,
                                'Irrigation': crop.irrigationMethod,
                                'Sowing': _dateText(crop.sowingDate),
                                'Harvest': _dateText(crop.expectedHarvestDate),
                                'Status': crop.status,
                              },
                            ),
                            if (crop.notes != null &&
                                crop.notes!.trim().isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Notes',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(crop.notes!),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              onPressed: cropProvider.isLoading
                                  ? null
                                  : () async {
                                      await cropProvider.deleteCrop(
                                        user.id,
                                        crop.id,
                                      );

                                      if (!context.mounted ||
                                          cropProvider.hasError) {
                                        return;
                                      }

                                      Navigator.of(context).pop();
                                    },
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Remove crop'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  static String _dateText(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid({required this.values});

  final Map<String, String> values;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 640 ? 3 : 2;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: values.entries
              .map(
                (entry) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.key,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(entry.value),
                      ],
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}
