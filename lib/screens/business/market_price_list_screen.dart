import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/market_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/business/business_cards.dart';

class MarketPriceListScreen extends StatefulWidget {
  const MarketPriceListScreen({super.key});

  @override
  State<MarketPriceListScreen> createState() => _MarketPriceListScreenState();
}

class _MarketPriceListScreenState extends State<MarketPriceListScreen> {
  final _queryController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _marketController = TextEditingController();
  bool _requestedLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedLoad) {
      return;
    }
    _requestedLoad = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _queryController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _marketController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      return;
    }
    final cropProvider = context.read<CropProvider>();
    if (cropProvider.crops.isEmpty) {
      await cropProvider.loadCrops(user.id);
      if (!mounted) {
        return;
      }
    }
    final profile = context.read<ProfileProvider>().profile;
    final query = _queryController.text.trim().isEmpty &&
            cropProvider.activeCrops.isNotEmpty
        ? cropProvider.activeCrops.first.cropName
        : _queryController.text.trim();
    await context.read<MarketProvider>().loadPrices(
          cropName: query,
          profile: profile,
          crops: cropProvider.activeCrops,
          state: _stateController.text,
          district: _districtController.text,
          market: _marketController.text,
        );
  }

  void _applyFilters() {
    context.read<MarketProvider>().applyFilters(
          query: _queryController.text,
          state: _stateController.text,
          district: _districtController.text,
          market: _marketController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;

    return Scaffold(
      appBar: AppBar(title: Text(strings.marketPrices)),
      body: SafeArea(
        child: Consumer<MarketProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.prices.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.hasError && provider.failure != null) {
              return BusinessStateView(
                message: provider.failure!.message,
                retryLabel: strings.retry,
                onRetry: _load,
              );
            }
            return RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _MarketFilters(
                    queryController: _queryController,
                    stateController: _stateController,
                    districtController: _districtController,
                    marketController: _marketController,
                    onChanged: _applyFilters,
                  ),
                  const SizedBox(height: 12),
                  if (provider.prices.isEmpty)
                    BusinessStateView(message: strings.noData)
                  else
                    ...provider.prices.map(
                      (price) => BusinessCard(
                        icon: Icons.storefront_outlined,
                        title: '${price.cropName} - ${price.marketName}',
                        subtitle:
                            '${price.district}, ${price.state}\n${strings.averagePrice}: ${price.averagePrice.toStringAsFixed(0)} / ${price.unit}',
                        onTap: () => Navigator.of(context).pushNamed(
                          RouteNames.marketDetail,
                          arguments: price.id,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MarketFilters extends StatelessWidget {
  const _MarketFilters({
    required this.queryController,
    required this.stateController,
    required this.districtController,
    required this.marketController,
    required this.onChanged,
  });

  final TextEditingController queryController;
  final TextEditingController stateController;
  final TextEditingController districtController;
  final TextEditingController marketController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    return BusinessSection(
      title: strings.filter,
      children: [
        TextField(
          controller: queryController,
          decoration: InputDecoration(labelText: strings.searchCrop),
          onChanged: (_) => onChanged(),
        ),
        TextField(
          controller: stateController,
          decoration: InputDecoration(labelText: strings.state),
          onChanged: (_) => onChanged(),
        ),
        TextField(
          controller: districtController,
          decoration: InputDecoration(labelText: strings.district),
          onChanged: (_) => onChanged(),
        ),
        TextField(
          controller: marketController,
          decoration: InputDecoration(labelText: strings.marketName),
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}
