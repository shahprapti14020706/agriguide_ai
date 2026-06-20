import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/crop_calendar_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/business/business_cards.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  bool _built = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_built) {
      return;
    }
    _built = true;
    final crops = context.read<CropProvider>().activeCrops;
    context.read<CropCalendarProvider>().buildCalendars(crops);
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final provider = context.watch<CropCalendarProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(strings.cropCalendar)),
      body: SafeArea(
        child: provider.calendars.isEmpty
            ? BusinessStateView(message: strings.noData)
            : ListView(
                padding: const EdgeInsets.all(16),
                children: provider.calendars
                    .map(
                      (calendar) => BusinessSection(
                        title: calendar.cropName,
                        children: calendar.activities
                            .map(
                              (activity) => DetailRow(
                                label: activity.type,
                                value:
                                    '${activity.scheduledDate.day}/${activity.scheduledDate.month}/${activity.scheduledDate.year}',
                              ),
                            )
                            .toList(growable: false),
                      ),
                    )
                    .toList(growable: false),
              ),
      ),
    );
  }
}
