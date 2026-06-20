import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/scheme_provider.dart';
import '../../widgets/business/business_cards.dart';

class SchemeListScreen extends StatefulWidget {
  const SchemeListScreen({super.key});

  @override
  State<SchemeListScreen> createState() => _SchemeListScreenState();
}

class _SchemeListScreenState extends State<SchemeListScreen> {
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
    await context.read<SchemeProvider>().loadSchemes(
          profile: context.read<ProfileProvider>().profile,
          crops: cropProvider.activeCrops,
        );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    return Scaffold(
      appBar: AppBar(title: Text(strings.governmentSchemes)),
      body: SafeArea(
        child: Consumer<SchemeProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.schemes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.hasError && provider.failure != null) {
              return BusinessStateView(
                message: provider.failure!.message,
                retryLabel: strings.retry,
                onRetry: _load,
              );
            }
            final schemes = provider.recommendedSchemes.isEmpty
                ? provider.schemes
                : provider.recommendedSchemes;
            if (schemes.isEmpty) {
              return BusinessStateView(message: strings.noData);
            }
            return RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: schemes
                    .map(
                      (scheme) => BusinessCard(
                        icon: Icons.account_balance_outlined,
                        title: scheme.name,
                        subtitle: '${scheme.department}\n${scheme.description}',
                        onTap: () => Navigator.of(context).pushNamed(
                          RouteNames.schemeDetails,
                          arguments: scheme.id,
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            );
          },
        ),
      ),
    );
  }
}
