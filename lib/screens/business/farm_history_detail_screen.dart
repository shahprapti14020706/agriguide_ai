import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/farm_history_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/business/business_cards.dart';

class FarmHistoryDetailScreen extends StatelessWidget {
  const FarmHistoryDetailScreen({required this.historyId, super.key});

  final String historyId;

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final item = context.watch<FarmHistoryProvider>().byId(historyId);
    return Scaffold(
      appBar: AppBar(title: Text(strings.farmHistory)),
      body: SafeArea(
        child: item == null
            ? BusinessStateView(message: strings.noData)
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  BusinessSection(
                    title: item.title,
                    children: [
                      DetailRow(label: strings.type, value: item.type),
                      DetailRow(
                        label: strings.description,
                        value: item.description,
                      ),
                      if (item.cropName != null)
                        DetailRow(
                          label: strings.activeCrops,
                          value: item.cropName!,
                        ),
                      DetailRow(
                        label: strings.dueDate,
                        value:
                            '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
