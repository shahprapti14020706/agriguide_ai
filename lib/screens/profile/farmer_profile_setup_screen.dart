import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/profile_provider.dart';
import 'farmer_profile_form.dart';

class FarmerProfileSetupScreen extends StatelessWidget {
  const FarmerProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final strings = context.watch<LanguageProvider>().strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.profileSetup),
      ),
      body: SafeArea(
        child: user == null
            ? Center(child: Text(strings.signIn))
            : Consumer<ProfileProvider>(
                builder: (context, profileProvider, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: FarmerProfileForm(
                          user: user,
                          initialProfile: profileProvider.profile,
                          submitLabel: strings.saveProfile,
                          loading: profileProvider.isLoading,
                          onSubmit: (profile) async {
                            await profileProvider.saveProfile(profile);

                            if (!context.mounted || profileProvider.hasError) {
                              return;
                            }

                            Navigator.of(context).pushReplacementNamed(
                              RouteNames.dashboard,
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
