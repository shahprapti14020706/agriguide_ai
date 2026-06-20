import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../providers/market_provider.dart';
import '../../widgets/business/business_cards.dart';

class MarketPriceDetailScreen extends StatelessWidget {
  const MarketPriceDetailScreen({required this.priceId, super.key});

  final String priceId;

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final provider = context.watch<MarketProvider>();
    final price = provider.byId(priceId);

    return Scaffold(
      appBar: AppBar(title: Text(strings.marketPrices)),
      body: SafeArea(
        child: price == null
            ? BusinessStateView(message: strings.noData)
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  BusinessSection(
                    title: '${price.cropName} - ${price.marketName}',
                    children: [
                      DetailRow(label: strings.district, value: price.district),
                      DetailRow(label: strings.state, value: price.state),
                      DetailRow(
                        label: strings.minimumPrice,
                        value:
                            '${price.minimumPrice.toStringAsFixed(0)} / ${price.unit}',
                      ),
                      DetailRow(
                        label: strings.maximumPrice,
                        value:
                            '${price.maximumPrice.toStringAsFixed(0)} / ${price.unit}',
                      ),
                      DetailRow(
                        label: strings.averagePrice,
                        value:
                            '${price.averagePrice.toStringAsFixed(0)} / ${price.unit}',
                      ),
                      DetailRow(
                        label: strings.priceTrend,
                        value: price.trendDirection,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BusinessSection(
                    title: strings.sellingSuggestion,
                    children: [
                      Text(provider.suggestionFor(price)),
                      if (price.advisoryNote.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(price.advisoryNote),
                      ],
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
