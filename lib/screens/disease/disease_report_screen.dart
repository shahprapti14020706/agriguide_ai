import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/disease_report_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/disease_detection_provider.dart';

class DiseaseReportScreen extends StatelessWidget {
  const DiseaseReportScreen({
    required this.reportId,
    super.key,
  });

  final String reportId;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final provider = context.watch<DiseaseDetectionProvider>();
    final report = provider.reportById(reportId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Report'),
        actions: [
          if (user != null && report != null)
            IconButton(
              tooltip: 'Delete report',
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      await provider.deleteReport(user.id, report.id);

                      if (context.mounted && !provider.hasError) {
                        Navigator.of(context).pop();
                      }
                    },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? const Center(child: Text('Please sign in to view reports.'))
            : report == null
                ? const Center(child: Text('Disease report not found.'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ReportImage(imageUrl: report.imageUrl),
                            const SizedBox(height: 16),
                            _ReportHeader(report: report),
                            const SizedBox(height: 16),
                            _ReportSection(
                              title: 'Visible Symptoms',
                              values: report.symptoms,
                            ),
                            _ReportSection(
                              title: 'Possible Causes',
                              values: report.causes,
                            ),
                            _ReportSection(
                              title: 'Recommended Treatment',
                              values: report.treatment,
                            ),
                            _ReportSection(
                              title: 'Preventive Measures',
                              values: report.prevention,
                            ),
                            _ExpertAdviceCard(
                              advice: report.recommendedAction,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}

class _ReportImage extends StatelessWidget {
  const _ReportImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    final source = imageUrl.trim();
    if (source.isEmpty) {
      return const _ReportImageFallback();
    }

    final dataBytes = _dataImageBytes(source);
    if (dataBytes != null) {
      return Image.memory(
        dataBytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _ReportImageFallback(),
      );
    }

    if (_isNetworkImage(source) || kIsWeb) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _ReportImageFallback(),
      );
    }

    return Image.file(
      File(source),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _ReportImageFallback(),
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
}

class _ReportImageFallback extends StatelessWidget {
  const _ReportImageFallback();

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

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.report});

  final DiseaseReportModel report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Possible Disease',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              report.diseaseName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _MetricChip(
                  icon: Icons.analytics_outlined,
                  label:
                      'Confidence ${(report.confidenceScore * 100).round()}%',
                ),
                _MetricChip(
                  icon: Icons.warning_amber_outlined,
                  label: '${report.severity} Severity',
                ),
                _MetricChip(
                  icon: Icons.local_florist_outlined,
                  label: report.plantPart,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({
    required this.title,
    required this.values,
  });

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              ...values.map(
                (value) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(value)),
                    ],
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

class _ExpertAdviceCard extends StatelessWidget {
  const _ExpertAdviceCard({required this.advice});

  final String advice;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.support_agent_outlined,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'When To Contact Expert',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    advice,
                    style: TextStyle(color: colorScheme.onPrimaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
