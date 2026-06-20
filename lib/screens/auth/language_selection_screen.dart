import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/route_names.dart';
import '../../core/localization/language_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/profile_provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  Future<void> _selectLanguage(
    BuildContext context,
    AppLanguage language,
  ) async {
    final languageProvider = context.read<LanguageProvider>();
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    await languageProvider.selectLanguage(language);

    if (!context.mounted) {
      return;
    }

    final user = authProvider.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacementNamed(RouteNames.login);
      return;
    }

    await profileProvider.loadProfile(user.id);
    if (!context.mounted) {
      return;
    }

    final profile = profileProvider.profile;
    if (profile != null) {
      await profileProvider.updateProfile(
        profile.copyWith(preferredLanguage: language.code),
      );
    }

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      profileProvider.hasCompletedProfile
          ? RouteNames.dashboard
          : RouteNames.profileSetup,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final selected = context.watch<LanguageProvider>().language;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.language_outlined,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    strings.chooseLanguage,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  for (final language in AppLanguage.values) ...[
                    _LanguageTile(
                      language: language,
                      selected: selected == language,
                      onTap: () => _selectLanguage(context, language),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          selected ? Icons.check_circle : Icons.radio_button_unchecked,
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        title: Text(language.label),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
