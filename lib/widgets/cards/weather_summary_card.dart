import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/weather_model.dart';
import '../../providers/language_provider.dart';

class WeatherSummaryCard extends StatelessWidget {
  const WeatherSummaryCard({
    required this.weather,
    super.key,
  });

  final WeatherModel? weather;

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;

    return _SummaryCard(
      icon: Icons.wb_cloudy_outlined,
      title: strings.weatherSummary,
      child: weather == null
          ? Text(strings.weatherAdvisory)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weather!.temperature.toStringAsFixed(0)} C - ${_condition(weather!)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  weather!.suggestedAction.isEmpty
                      ? weather!.possibleImpact
                      : weather!.suggestedAction,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
    );
  }

  String _condition(WeatherModel weather) {
    if (weather.rainProbability >= 65) {
      return 'Rain likely';
    }
    if (weather.temperature >= 34) {
      return 'Hot';
    }
    if (weather.humidity >= 75) {
      return 'Humid';
    }
    return 'Field work suitable';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

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
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
