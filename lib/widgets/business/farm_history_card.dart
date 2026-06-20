import 'package:flutter/material.dart';

import '../../models/farm_history_model.dart';

class FarmHistoryCard extends StatelessWidget {
  const FarmHistoryCard({
    required this.item,
    required this.onTap,
    super.key,
  });

  final FarmHistoryModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.history_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(item.title),
        subtitle: Text('${item.type}\n${item.description}'),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
