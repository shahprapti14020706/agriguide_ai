import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/crop_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/irrigation_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/advisory/advisory_cards.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
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
    final weatherProvider = context.read<WeatherProvider>();
    final profile = context.read<ProfileProvider>().profile;
    final language = context.read<LanguageProvider>().language;
    if (cropProvider.crops.isEmpty) {
      await cropProvider.loadCrops(user.id);
      if (!mounted) {
        return;
      }
    }

    if (weatherProvider.currentWeather == null) {
      await weatherProvider.loadWeather(
        userId: user.id,
        profile: profile,
        crops: cropProvider.activeCrops,
        language: language,
      );
      if (!mounted) {
        return;
      }
    }

    if (!mounted) {
      return;
    }

    await context.read<IrrigationProvider>().loadRecommendations(
          userId: user.id,
          crop: _selectedCrop(cropProvider),
          weather: weatherProvider.currentWeather,
          language: language,
        );
  }

  Future<void> _refresh() async {
    final user = context.read<AuthProvider>().currentUser;
    final crop = _selectedCrop(context.read<CropProvider>());
    if (user == null || crop == null) {
      return;
    }

    await context.read<IrrigationProvider>().generateRecommendation(
          userId: user.id,
          crop: crop,
          weather: context.read<WeatherProvider>().currentWeather,
          language: context.read<LanguageProvider>().language,
        );
  }

  CropModel? _selectedCrop(CropProvider provider) {
    return provider.activeCrops.isEmpty ? null : provider.activeCrops.first;
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final user = context.watch<AuthProvider>().currentUser;
    final crop = _selectedCrop(context.watch<CropProvider>());

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.irrigationAdvisory),
        actions: [
          IconButton(
            tooltip: strings.refresh,
            onPressed: crop == null ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? AdvisoryStateView(icon: Icons.login, message: strings.signIn)
            : crop == null
                ? AdvisoryStateView(
                    icon: Icons.grass_outlined,
                    message: strings.noActiveCrop,
                  )
                : Consumer<IrrigationProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading &&
                          provider.latestRecommendation == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.hasError && provider.failure != null) {
                        return AdvisoryStateView(
                          icon: Icons.error_outline,
                          message: provider.failure!.message,
                          actionLabel: strings.retry,
                          onAction: _load,
                        );
                      }

                      final recommendation = provider.latestRecommendation;
                      if (recommendation == null) {
                        return AdvisoryStateView(
                          icon: Icons.water_drop_outlined,
                          message: strings.irrigationAdvisory,
                          actionLabel: strings.refresh,
                          onAction: _refresh,
                        );
                      }

                      final nextDate = recommendation.nextIrrigationDate;

                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            AdvisoryInfoCard(
                              title: strings.waterRequirement,
                              icon: Icons.water_drop_outlined,
                              children: [
                                AdvisoryMetricRow(
                                  label: strings.activeCrops,
                                  value:
                                      '${recommendation.cropName} - ${recommendation.cropStage}',
                                ),
                                AdvisoryMetricRow(
                                  label: strings.waterRequirement,
                                  value: recommendation.waterRequirement,
                                ),
                                AdvisoryMetricRow(
                                  label: strings.irrigationFrequency,
                                  value: recommendation.irrigationFrequency,
                                ),
                                AdvisoryMetricRow(
                                  label: strings.nextIrrigationDate,
                                  value:
                                      '${nextDate.day}/${nextDate.month}/${nextDate.year}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AdvisoryInfoCard(
                              title: strings.irrigationSchedule,
                              icon: Icons.event_note_outlined,
                              children: [
                                AdvisoryBulletList(
                                  items: recommendation.schedule,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AdvisoryInfoCard(
                              title: strings.irrigationAlerts,
                              icon: Icons.warning_amber_outlined,
                              children: [
                                AdvisoryBulletList(
                                  items: recommendation.alerts,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AdvisoryInfoCard(
                              title: strings.advisoryNotes,
                              icon: Icons.tips_and_updates_outlined,
                              children: [
                                AdvisoryBulletList(
                                  items: recommendation.advisoryNotes,
                                ),
                              ],
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
