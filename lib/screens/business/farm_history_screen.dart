import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/farm_history_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/business/business_cards.dart';
import '../../widgets/business/farm_history_card.dart';

class FarmHistoryScreen extends StatefulWidget {
  const FarmHistoryScreen({super.key});

  @override
  State<FarmHistoryScreen> createState() => _FarmHistoryScreenState();
}

class _FarmHistoryScreenState extends State<FarmHistoryScreen> {
  bool _requestedLoad = false;
  String _type = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedLoad) {
      return;
    }
    _requestedLoad = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
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
    await context.read<FarmHistoryProvider>().loadHistory(
          user.id,
          crops: cropProvider.activeCrops,
        );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    return Scaffold(
      appBar: AppBar(title: Text(strings.farmHistory)),
      body: SafeArea(
        child: Consumer<FarmHistoryProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.history.isEmpty) {
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
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: InputDecoration(labelText: strings.filter),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('All')),
                      DropdownMenuItem(
                        value: 'Crop Added',
                        child: Text('Crop Added'),
                      ),
                      DropdownMenuItem(
                        value: 'Disease Report',
                        child: Text('Disease Report'),
                      ),
                      DropdownMenuItem(
                        value: 'Weather Advisory',
                        child: Text('Weather Advisory'),
                      ),
                      DropdownMenuItem(
                        value: 'Reminder Completed',
                        child: Text('Reminder Completed'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _type = value ?? '');
                      provider.applyFilters(type: _type);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (provider.history.isEmpty)
                    BusinessStateView(message: strings.noData)
                  else
                    ...provider.history.map(
                      (item) => FarmHistoryCard(
                        item: item,
                        onTap: () => Navigator.of(context).pushNamed(
                          RouteNames.farmHistoryDetail,
                          arguments: item.id,
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
