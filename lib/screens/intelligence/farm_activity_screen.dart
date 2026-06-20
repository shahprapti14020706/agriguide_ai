import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/farm_activity_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/business/business_cards.dart';

class FarmActivityScreen extends StatefulWidget {
  const FarmActivityScreen({super.key});

  @override
  State<FarmActivityScreen> createState() => _FarmActivityScreenState();
}

class _FarmActivityScreenState extends State<FarmActivityScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) {
      return;
    }
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      await context.read<FarmActivityProvider>().loadActivities(user.id);
    }
  }

  Future<void> _quickLog(String type) async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      return;
    }
    final provider = context.read<FarmActivityProvider>();
    final activity = provider.createActivity(
      userId: user.id,
      type: type,
      title: type,
      description: '$type activity logged.',
    );
    await provider.saveActivity(activity);
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final provider = context.watch<FarmActivityProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(strings.farmActivities)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in const [
                  'Irrigation',
                  'Fertilizer',
                  'Pesticide',
                  'Disease Treatment',
                  'Harvest',
                ])
                  FilledButton(
                    onPressed: () => _quickLog(type),
                    child: Text(type),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.activities.isEmpty)
              BusinessStateView(message: strings.noData)
            else
              ...provider.activities.map(
                (activity) => BusinessCard(
                  icon: Icons.agriculture_outlined,
                  title: activity.title,
                  subtitle:
                      '${activity.type}\n${activity.activityDate.day}/${activity.activityDate.month}/${activity.activityDate.year}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
