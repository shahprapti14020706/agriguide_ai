import 'package:flutter/material.dart';

import '../../models/government_scheme_model.dart';

class SchemeRecommendationCard extends StatelessWidget {
  const SchemeRecommendationCard({
    required this.scheme,
    required this.onTap,
    super.key,
  });

  final GovernmentSchemeModel scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.account_balance_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(scheme.name),
        subtitle: Text(
          scheme.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
