import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/business/business_cards.dart';
import '../../widgets/business/notification_card.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
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
    if (user != null) {
      await context.read<NotificationProvider>().loadNotifications(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    return Scaffold(
      appBar: AppBar(title: Text(strings.notifications)),
      body: SafeArea(
        child: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.hasError && provider.failure != null) {
              return BusinessStateView(
                message: provider.failure!.message,
                retryLabel: strings.retry,
                onRetry: _load,
              );
            }
            if (provider.notifications.isEmpty) {
              return BusinessStateView(message: strings.noData);
            }
            return RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: provider.notifications
                    .map(
                      (notification) => NotificationCard(
                        notification: notification,
                        onTap: () => Navigator.of(context).pushNamed(
                          RouteNames.notificationDetail,
                          arguments: notification.id,
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
