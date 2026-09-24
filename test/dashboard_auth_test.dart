import 'package:agriguide_ai/app/routes/route_names.dart';
import 'package:agriguide_ai/di/service_locator.dart';
import 'package:agriguide_ai/providers/auth_provider.dart';
import 'package:agriguide_ai/providers/language_provider.dart';
import 'package:agriguide_ai/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('direct dashboard entry without a session redirects before reads',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await setupServiceLocator();
    addTearDown(() => sl.reset());

    // Deliberately omit data providers: an unauthenticated visit must never
    // reach CropProvider or DashboardProvider and start their Firestore reads.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
          ChangeNotifierProvider(create: (_) => sl<LanguageProvider>()),
        ],
        child: MaterialApp(
          home: const DashboardScreen(),
          routes: {
            RouteNames.login: (_) => const Scaffold(body: Text('Login route')),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Login route'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
