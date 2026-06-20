import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/business/business_cards.dart';
import '../../widgets/business/reminder_card.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
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
    await context.read<ReminderProvider>().loadReminders(
          user.id,
          crops: cropProvider.activeCrops,
        );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      appBar: AppBar(title: Text(strings.reminders)),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.of(context).pushNamed(RouteNames.addReminder),
              icon: const Icon(Icons.add),
              label: Text(strings.addReminder),
            ),
      body: SafeArea(
        child: Consumer<ReminderProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.reminders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.hasError && provider.failure != null) {
              return BusinessStateView(
                message: provider.failure!.message,
                retryLabel: strings.retry,
                onRetry: _load,
              );
            }
            if (provider.reminders.isEmpty) {
              return BusinessStateView(message: strings.noData);
            }
            return RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: provider.reminders
                    .map(
                      (reminder) => ReminderCard(
                        reminder: reminder,
                        onTap: () => Navigator.of(context).pushNamed(
                          RouteNames.reminderDetail,
                          arguments: reminder.id,
                        ),
                        onComplete: () => provider.complete(reminder),
                        onSnooze: () => provider.snooze(reminder),
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
