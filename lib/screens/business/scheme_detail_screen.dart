import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../providers/scheme_provider.dart';
import '../../widgets/business/business_cards.dart';

class SchemeDetailScreen extends StatelessWidget {
  const SchemeDetailScreen({required this.schemeId, super.key});

  final String schemeId;

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final scheme = context.watch<SchemeProvider>().byId(schemeId);

    return Scaffold(
      appBar: AppBar(title: Text(strings.governmentSchemes)),
      body: SafeArea(
        child: scheme == null
            ? BusinessStateView(message: strings.noData)
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  BusinessSection(
                    title: scheme.name,
                    children: [
                      DetailRow(label: strings.type, value: scheme.schemeLevel),
                      DetailRow(
                        label: strings.description,
                        value: scheme.description,
                      ),
                      if (scheme.deadline != null)
                        DetailRow(
                          label: strings.deadline,
                          value:
                              '${scheme.deadline!.day}/${scheme.deadline!.month}/${scheme.deadline!.year}',
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BusinessSection(
                    title: strings.eligibility,
                    children: [BulletItems(items: scheme.eligibility)],
                  ),
                  BusinessSection(
                    title: strings.benefits,
                    children: [BulletItems(items: scheme.benefits)],
                  ),
                  BusinessSection(
                    title: strings.requiredDocuments,
                    children: [BulletItems(items: scheme.requiredDocuments)],
                  ),
                  BusinessSection(
                    title: strings.applicationProcess,
                    children: [
                      BulletItems(items: scheme.applicationProcess),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
