import 'package:flutter/material.dart';

import '../../models/disease_report_model.dart';

class DiseaseResultCard extends StatelessWidget {
  const DiseaseResultCard({
    required this.report,
    this.onTap,
    super.key,
  });

  final DiseaseReportModel report;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _severityColor(
                      colorScheme,
                      report.severity,
                    ),
                    child: const Icon(Icons.health_and_safety_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.diseaseName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        Text(
                          '${report.severity} severity • ${(report.confidenceScore * 100).round()}% confidence',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              Text(report.recommendedAction),
            ],
          ),
        ),
      ),
    );
  }

  Color _severityColor(ColorScheme colorScheme, String severity) {
    return switch (severity) {
      'High' => colorScheme.errorContainer,
      'Moderate' => colorScheme.tertiaryContainer,
      _ => colorScheme.primaryContainer,
    };
  }
}
