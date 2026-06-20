import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/route_names.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/profile_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveStartRoute());
  }

  Future<void> _resolveStartRoute() async {
    final authProvider = context.read<AuthProvider>();
    final languageProvider = context.read<LanguageProvider>();
    final profileProvider = context.read<ProfileProvider>();

    await authProvider.initialize();
    await languageProvider.initialize();

    if (!mounted) {
      return;
    }

    if (!authProvider.onboardingComplete) {
      Navigator.of(context).pushReplacementNamed(RouteNames.onboarding);
      return;
    }

    if (!languageProvider.hasSelectedLanguage) {
      Navigator.of(context).pushReplacementNamed(
        RouteNames.languageSelection,
      );
      return;
    }

    final user = authProvider.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacementNamed(RouteNames.login);
      return;
    }

    await profileProvider.loadProfile(user.id);

    if (!mounted) {
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco,
              size: 72,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.appTagline,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
