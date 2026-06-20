import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/route_names.dart';
import '../../core/localization/language_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/cards/ai_insight_card.dart';
import '../../widgets/cards/market_snapshot_card.dart';
import '../../widgets/cards/reminder_summary_card.dart';
import '../../widgets/cards/weather_summary_card.dart';
import '../../widgets/crop/active_crop_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _requestedLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_requestedLoad) {
      return;
    }

    _requestedLoad = true;
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await context.read<CropProvider>().loadCrops(user.id);
        if (mounted) {
          await context.read<DashboardProvider>().loadDashboard(
                user.id,
                language: context.read<LanguageProvider>().language,
              );
        }
      });
    }
  }

  Future<void> _refresh(String userId) async {
    await context.read<CropProvider>().loadCrops(userId);
    if (mounted) {
      await context.read<DashboardProvider>().loadDashboard(
            userId,
            language: context.read<LanguageProvider>().language,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final strings = context.watch<LanguageProvider>().strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.dashboard),
        actions: [
          IconButton(
            tooltip: strings.agriGuideAi,
            onPressed: () => Navigator.of(context).pushNamed(
              RouteNames.aiChat,
            ),
            icon: const Icon(Icons.auto_awesome_outlined),
          ),
          IconButton(
            tooltip: strings.diseaseDetection,
            onPressed: () => Navigator.of(context).pushNamed(
              RouteNames.diseaseDetection,
            ),
            icon: const Icon(Icons.health_and_safety_outlined),
          ),
          IconButton(
            tooltip: strings.farmerProfileTooltip,
            onPressed: () => Navigator.of(context).pushNamed(
              RouteNames.profileEdit,
            ),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? Center(child: Text(strings.noUserDashboard))
            : Consumer2<DashboardProvider, CropProvider>(
                builder: (context, dashboardProvider, cropProvider, _) {
                  if (dashboardProvider.isLoading &&
                      dashboardProvider.activeCrops.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (dashboardProvider.hasError &&
                      dashboardProvider.failure != null) {
                    return Center(
                      child: Text(dashboardProvider.failure!.message),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => _refresh(user.id),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _DashboardHeader(
                          strings: strings,
                          activeCropCount: cropProvider.activeCrops.length,
                          onAddCrop: () => Navigator.of(context).pushNamed(
                            RouteNames.addCrop,
                          ),
                          onViewCrops: () => Navigator.of(context).pushNamed(
                            RouteNames.crops,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SummaryGrid(
                          children: [
                            WeatherSummaryCard(
                              weather: dashboardProvider.weatherSummary,
                            ),
                            ReminderSummaryCard(
                              reminders: dashboardProvider.pendingReminders,
                            ),
                            MarketSnapshotCard(
                              marketPrice: dashboardProvider.marketSnapshot,
                            ),
                            AiInsightCard(
                              insight: dashboardProvider.aiInsight,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _AdvisoryShortcutGrid(strings: strings),
                        const SizedBox(height: 16),
                        _BusinessShortcutGrid(strings: strings),
                        const SizedBox(height: 20),
                        Text(
                          strings.activeCrops,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        if (cropProvider.activeCrops.isEmpty)
                          _EmptyDashboardCrops(strings: strings)
                        else
                          ...cropProvider.activeCrops.map(
                            (crop) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ActiveCropCard(
                                crop: crop,
                                stageEstimate: cropProvider.estimateStage(crop),
                                onTap: () => Navigator.of(context).pushNamed(
                                  RouteNames.cropDetails,
                                  arguments: crop.id,
                                ),
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.strings,
    required this.activeCropCount,
    required this.onAddCrop,
    required this.onViewCrops,
  });

  final LanguageStrings strings;
  final int activeCropCount;
  final VoidCallback onAddCrop;
  final VoidCallback onViewCrops;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.farmOverview,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.activeCropsCount(activeCropCount),
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onAddCrop,
                icon: const Icon(Icons.add),
                label: Text(strings.addCrop),
              ),
              OutlinedButton.icon(
                onPressed: onViewCrops,
                icon: const Icon(Icons.list_alt),
                label: Text(strings.viewCrops),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 760 ? 4 : 2;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: constraints.maxWidth > 760 ? 1.25 : 1.15,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: children,
        );
      },
    );
  }
}

class _BusinessShortcutGrid extends StatelessWidget {
  const _BusinessShortcutGrid({required this.strings});

  final LanguageStrings strings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 760 ? 3 : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: constraints.maxWidth > 760 ? 2.8 : 4.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _AdvisoryShortcutCard(
              title: strings.marketPrices,
              icon: Icons.storefront_outlined,
              onTap: () => Navigator.of(context).pushNamed(
                RouteNames.marketPrices,
              ),
            ),
            _AdvisoryShortcutCard(
              title: strings.governmentSchemes,
              icon: Icons.account_balance_outlined,
              onTap: () => Navigator.of(context).pushNamed(
                RouteNames.schemes,
              ),
            ),
            _AdvisoryShortcutCard(
              title: strings.reminders,
              icon: Icons.notifications_active_outlined,
              onTap: () => Navigator.of(context).pushNamed(
                RouteNames.reminders,
              ),
            ),
            _AdvisoryShortcutCard(
              title: strings.notifications,
              icon: Icons.mark_email_unread_outlined,
              onTap: () => Navigator.of(context).pushNamed(
                RouteNames.notifications,
              ),
            ),
            _AdvisoryShortcutCard(
              title: strings.farmHistory,
              icon: Icons.history_outlined,
              onTap: () => Navigator.of(context).pushNamed(
                RouteNames.farmHistory,
              ),
            ),
            _AdvisoryShortcutCard(
              title: strings.cropCalendar,
              icon: Icons.calendar_month_outlined,
              onTap: () => Navigator.of(context).pushNamed(
                RouteNames.cropCalendar,
              ),
            ),
            _AdvisoryShortcutCard(
              title: strings.farmActivities,
              icon: Icons.agriculture_outlined,
              onTap: () => Navigator.of(context).pushNamed(
                RouteNames.farmActivities,
              ),
            ),
            _AdvisoryShortcutCard(
              title: strings.cropGallery,
              icon: Icons.photo_library_outlined,
              onTap: () => Navigator.of(context).pushNamed(
                RouteNames.cropGallery,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AdvisoryShortcutGrid extends StatelessWidget {
  const _AdvisoryShortcutGrid({required this.strings});

  final LanguageStrings strings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 760 ? 3 : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: constraints.maxWidth > 760 ? 2.8 : 4.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _AdvisoryShortcutCard(
              title: strings.weatherAdvisory,
              icon: Icons.wb_cloudy_outlined,
              onTap: () => Navigator.of(context).pushNamed(
                RouteNames.weather,
              ),
            ),
            _AdvisoryShortcutCard(
              title: strings.fertilizerAdvisory,
              icon: Icons.science_outlined,
              onTap: () => Navigator.of(context).pushNamed(
                RouteNames.fertilizerAdvisor,
              ),
            ),
            _AdvisoryShortcutCard(
              title: strings.irrigationAdvisory,
              icon: Icons.water_drop_outlined,
              onTap: () => Navigator.of(context).pushNamed(
                RouteNames.irrigationAdvisor,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AdvisoryShortcutCard extends StatelessWidget {
  const _AdvisoryShortcutCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDashboardCrops extends StatelessWidget {
  const _EmptyDashboardCrops({required this.strings});

  final LanguageStrings strings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.grass_outlined,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              strings.addCropToStart,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
