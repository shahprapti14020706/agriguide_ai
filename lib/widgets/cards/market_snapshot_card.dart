import 'package:flutter/material.dart';

import '../../models/market_price_model.dart';

class MarketSnapshotCard extends StatelessWidget {
  const MarketSnapshotCard({
    required this.marketPrice,
    super.key,
  });

  final MarketPriceModel? marketPrice;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storefront_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Market Snapshot',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (marketPrice == null)
              const Text('Add an active crop to view local market prices.')
            else ...[
              Text(
                marketPrice!.cropName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rs ${marketPrice!.averagePrice.toStringAsFixed(0)} / ${marketPrice!.unit}',
              ),
              Text(
                'Trend: ${_trendLabel(marketPrice!.trendDirection)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _trendLabel(String trendDirection) {
    final trend = trendDirection.trim().toLowerCase();
    if (trend == 'up') {
      return 'Rising';
    }
    if (trend == 'down') {
      return 'Falling';
    }
    return 'Stable';
  }
}
