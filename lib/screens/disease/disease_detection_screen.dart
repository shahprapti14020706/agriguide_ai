import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/disease_detection_provider.dart';
import '../../widgets/disease/disease_result_card.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
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
        (_) => context.read<DiseaseDetectionProvider>().loadReports(user.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Detection'),
      ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed(
                RouteNames.diseaseUpload,
              ),
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Analyze'),
            ),
      body: SafeArea(
        child: user == null
            ? const Center(
                child: Text('Please sign in to analyze crop diseases.'),
              )
            : Consumer<DiseaseDetectionProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.reports.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.hasError && provider.failure != null) {
                    return Center(child: Text(provider.failure!.message));
                  }

                  if (provider.reports.isEmpty) {
                    return const _EmptyDiseaseHistory();
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadReports(user.id),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.reports.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final report = provider.reports[index];
                        return DiseaseResultCard(
                          report: report,
                          onTap: () => Navigator.of(context).pushNamed(
                            RouteNames.diseaseReport,
                            arguments: report.id,
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

class _EmptyDiseaseHistory extends StatelessWidget {
  const _EmptyDiseaseHistory();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              size: 56,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No disease reports yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Capture or upload a plant image to generate the first report.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
