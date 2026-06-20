import 'package:flutter/material.dart';

import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/language_selection_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/onboarding_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/ai/ai_chat_screen.dart';
import '../../screens/crops/add_crop_screen.dart';
import '../../screens/crops/crop_details_screen.dart';
import '../../screens/crops/crop_list_screen.dart';
import '../../screens/crops/edit_crop_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/disease/disease_detection_screen.dart';
import '../../screens/disease/disease_report_screen.dart';
import '../../screens/disease/image_upload_screen.dart';
import '../../screens/advisory/fertilizer_screen.dart';
import '../../screens/advisory/irrigation_screen.dart';
import '../../screens/advisory/weather_screen.dart';
import '../../screens/business/farm_history_detail_screen.dart';
import '../../screens/business/farm_history_screen.dart';
import '../../screens/business/market_price_detail_screen.dart';
import '../../screens/business/market_price_list_screen.dart';
import '../../screens/business/notification_detail_screen.dart';
import '../../screens/business/notification_list_screen.dart';
import '../../screens/business/reminder_detail_screen.dart';
import '../../screens/business/reminder_form_screen.dart';
import '../../screens/business/reminder_list_screen.dart';
import '../../screens/business/scheme_detail_screen.dart';
import '../../screens/business/scheme_list_screen.dart';
import '../../screens/intelligence/crop_calendar_screen.dart';
import '../../screens/intelligence/crop_gallery_screen.dart';
import '../../screens/intelligence/farm_activity_screen.dart';
import '../../screens/profile/farmer_profile_edit_screen.dart';
import '../../screens/profile/farmer_profile_setup_screen.dart';
import 'route_names.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget screen = switch (settings.name) {
      RouteNames.splash => const SplashScreen(),
      RouteNames.onboarding => const OnboardingScreen(),
      RouteNames.languageSelection => const LanguageSelectionScreen(),
      RouteNames.login => const LoginScreen(),
      RouteNames.register => const RegisterScreen(),
      RouteNames.forgotPassword => const ForgotPasswordScreen(),
      RouteNames.profileSetup => const FarmerProfileSetupScreen(),
      RouteNames.profileEdit => const FarmerProfileEditScreen(),
      RouteNames.profile => const FarmerProfileEditScreen(),
      RouteNames.dashboard => const DashboardScreen(),
      RouteNames.crops => const CropListScreen(),
      RouteNames.addCrop => const AddCropScreen(),
      RouteNames.aiChat => const AiChatScreen(),
      RouteNames.diseaseDetection => const DiseaseDetectionScreen(),
      RouteNames.diseaseUpload => const ImageUploadScreen(),
      RouteNames.weather => const WeatherScreen(),
      RouteNames.fertilizerAdvisor => const FertilizerScreen(),
      RouteNames.irrigationAdvisor => const IrrigationScreen(),
      RouteNames.marketPrices => const MarketPriceListScreen(),
      RouteNames.schemes => const SchemeListScreen(),
      RouteNames.reminders => const ReminderListScreen(),
      RouteNames.addReminder => const ReminderFormScreen(),
      RouteNames.notifications => const NotificationListScreen(),
      RouteNames.farmHistory => const FarmHistoryScreen(),
      RouteNames.cropCalendar => const CropCalendarScreen(),
      RouteNames.farmActivities => const FarmActivityScreen(),
      RouteNames.cropGallery => const CropGalleryScreen(),
      RouteNames.marketDetail => MarketPriceDetailScreen(
          priceId: settings.arguments as String? ?? '',
        ),
      RouteNames.schemeDetails => SchemeDetailScreen(
          schemeId: settings.arguments as String? ?? '',
        ),
      RouteNames.editReminder => ReminderFormScreen(
          reminderId: settings.arguments as String?,
        ),
      RouteNames.reminderDetail => ReminderDetailScreen(
          reminderId: settings.arguments as String? ?? '',
        ),
      RouteNames.notificationDetail => NotificationDetailScreen(
          notificationId: settings.arguments as String? ?? '',
        ),
      RouteNames.farmHistoryDetail => FarmHistoryDetailScreen(
          historyId: settings.arguments as String? ?? '',
        ),
      RouteNames.diseaseReport => DiseaseReportScreen(
          reportId: settings.arguments as String? ?? '',
        ),
      RouteNames.editCrop => EditCropScreen(
          cropId: settings.arguments as String? ?? '',
        ),
      RouteNames.cropDetails => CropDetailsScreen(
          cropId: settings.arguments as String? ?? '',
        ),
      _ => const LoginScreen(),
    };

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => screen,
    );
  }
}
