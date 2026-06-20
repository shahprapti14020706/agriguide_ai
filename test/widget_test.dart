import 'package:agriguide_ai/app/app.dart';
import 'package:agriguide_ai/core/constants/app_constants.dart';
import 'package:agriguide_ai/di/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('AgriGuideApp shows the splash screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await setupServiceLocator();

    await tester.pumpWidget(const AgriGuideApp());

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appTagline), findsOneWidget);
  });
}
