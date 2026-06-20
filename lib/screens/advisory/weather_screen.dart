import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/weather_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/advisory/advisory_cards.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
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

    final profileProvider = context.read<ProfileProvider>();
    final cropProvider = context.read<CropProvider>();

    if (profileProvider.profile == null) {
      await profileProvider.loadProfile(user.id);
    }
    if (cropProvider.crops.isEmpty) {
      await cropProvider.loadCrops(user.id);
    }

    if (!mounted) {
      return;
    }

    await context.read<WeatherProvider>().loadWeather(
          userId: user.id,
          profile: profileProvider.profile,
          crops: cropProvider.activeCrops,
          language: context.read<LanguageProvider>().language,
        );
  }

  Future<void> _refresh() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      return;
    }

    await context.read<WeatherProvider>().generateWeather(
          userId: user.id,
          profile: context.read<ProfileProvider>().profile,
          crops: context.read<CropProvider>().activeCrops,
          language: context.read<LanguageProvider>().language,
        );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.weatherAdvisory),
        actions: [
          IconButton(
            tooltip: strings.refresh,
            onPressed: user == null ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? AdvisoryStateView(
                icon: Icons.login,
                message: strings.signIn,
              )
            : Consumer<WeatherProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.currentWeather == null) {
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

                  final weather = provider.currentWeather;
                  if (weather == null) {
                    return AdvisoryStateView(
                      icon: Icons.wb_cloudy_outlined,
                      message: strings.weatherAdvisory,
                      actionLabel: strings.refresh,
                      onAction: _refresh,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _CurrentWeatherCard(weather: weather),
                        const SizedBox(height: 12),
                        _ForecastSection(weather: weather),
                        const SizedBox(height: 12),
                        AdvisoryInfoCard(
                          title: strings.weatherAlerts,
                          icon: Icons.warning_amber_outlined,
                          children: [
                            AdvisoryBulletList(items: weather.alerts),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AdvisoryInfoCard(
                          title: strings.aiWeatherRecommendation,
                          icon: Icons.auto_awesome_outlined,
                          children: [
                            AdvisoryMetricRow(
                              label: strings.weatherSummary,
                              value: weather.summary,
                            ),
                            AdvisoryMetricRow(
                              label: strings.possibleImpact,
                              value: weather.possibleImpact,
                            ),
                            AdvisoryMetricRow(
                              label: strings.suggestedAction,
                              value: weather.suggestedAction,
                            ),
                            AdvisoryMetricRow(
                              label: strings.preventiveMeasures,
                              value: weather.preventiveMeasures,
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

class _CurrentWeatherCard extends StatelessWidget {
  const _CurrentWeatherCard({required this.weather});

  final WeatherModel weather;

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;

    return AdvisoryInfoCard(
      title: strings.currentWeather,
      icon: Icons.wb_sunny_outlined,
      children: [
        Text(
          weather.location,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        AdvisoryMetricRow(
          label: strings.temperature,
          value: '${weather.temperature.toStringAsFixed(1)} C',
        ),
        AdvisoryMetricRow(
          label: strings.humidity,
          value: '${weather.humidity.toStringAsFixed(0)}%',
        ),
        AdvisoryMetricRow(
          label: strings.windSpeed,
          value: '${weather.windSpeed.toStringAsFixed(0)} km/h',
        ),
        AdvisoryMetricRow(
          label: strings.rainProbability,
          value: '${weather.rainProbability.toStringAsFixed(0)}%',
        ),
        AdvisoryMetricRow(
          label: strings.sunrise,
          value: _time(weather.sunrise),
        ),
        AdvisoryMetricRow(
          label: strings.sunset,
          value: _time(weather.sunset),
        ),
      ],
    );
  }
}

class _ForecastSection extends StatelessWidget {
  const _ForecastSection({required this.weather});

  final WeatherModel weather;

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;

    return AdvisoryInfoCard(
      title: strings.sevenDayForecast,
      icon: Icons.calendar_month_outlined,
      children: weather.forecast
          .map(
            (forecast) => AdvisoryMetricRow(
              label:
                  '${forecast.date.day}/${forecast.date.month}/${forecast.date.year}',
              value:
                  '${forecast.temperature.toStringAsFixed(0)} C, ${forecast.rainProbability.toStringAsFixed(0)}% - ${forecast.summary}',
            ),
          )
          .toList(growable: false),
    );
  }
}

String _time(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
