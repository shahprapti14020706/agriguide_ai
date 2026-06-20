abstract final class FirestoreCollections {
  static const users = 'users';
  static const crops = 'crops';
  static const cropStages = 'cropStages';
  static const chatHistory = 'chatHistory';
  static const messages = 'messages';
  static const diseaseReports = 'diseaseReports';
  static const fertilizerRecommendations = 'fertilizerRecommendations';
  static const irrigationRecommendations = 'irrigationRecommendations';
  static const weatherData = 'weatherData';
  static const marketPrices = 'marketPrices';
  static const schemes = 'schemes';
  static const reminders = 'reminders';
  static const notifications = 'notifications';
  static const farmHistory = 'farmHistory';
  static const farmActivities = 'farmActivities';
  static const cropImages = 'cropImages';
  static const knowledgeBase = 'knowledgeBase';
}

abstract final class FirestorePaths {
  static String user(String userId) => '${FirestoreCollections.users}/$userId';

  static String userCrops(String userId) =>
      '${user(userId)}/${FirestoreCollections.crops}';

  static String userCrop(String userId, String cropId) =>
      '${userCrops(userId)}/$cropId';

  static String cropStages(String cropName) =>
      '${FirestoreCollections.cropStages}/$cropName';

  static String userChatHistory(String userId) =>
      '${user(userId)}/${FirestoreCollections.chatHistory}';

  static String userChat(String userId, String chatId) =>
      '${userChatHistory(userId)}/$chatId';

  static String userChatMessages(String userId, String chatId) =>
      '${userChatHistory(userId)}/$chatId/${FirestoreCollections.messages}';

  static String userChatMessage(
    String userId,
    String chatId,
    String messageId,
  ) =>
      '${userChatMessages(userId, chatId)}/$messageId';

  static String userDiseaseReports(String userId) =>
      '${user(userId)}/${FirestoreCollections.diseaseReports}';

  static String userDiseaseReport(String userId, String reportId) =>
      '${userDiseaseReports(userId)}/$reportId';

  static String userFertilizerRecommendations(String userId) =>
      '${user(userId)}/${FirestoreCollections.fertilizerRecommendations}';

  static String userIrrigationRecommendations(String userId) =>
      '${user(userId)}/${FirestoreCollections.irrigationRecommendations}';

  static String userWeatherData(String userId) =>
      '${user(userId)}/${FirestoreCollections.weatherData}';

  static String userReminders(String userId) =>
      '${user(userId)}/${FirestoreCollections.reminders}';

  static String userReminder(String userId, String reminderId) =>
      '${userReminders(userId)}/$reminderId';

  static String userNotifications(String userId) =>
      '${user(userId)}/${FirestoreCollections.notifications}';

  static String userNotification(String userId, String notificationId) =>
      '${userNotifications(userId)}/$notificationId';

  static String userFarmHistory(String userId) =>
      '${user(userId)}/${FirestoreCollections.farmHistory}';

  static String userFarmHistoryItem(String userId, String historyId) =>
      '${userFarmHistory(userId)}/$historyId';

  static String userFarmActivities(String userId) =>
      '${user(userId)}/${FirestoreCollections.farmActivities}';

  static String userFarmActivity(String userId, String activityId) =>
      '${userFarmActivities(userId)}/$activityId';

  static String userCropImages(String userId) =>
      '${user(userId)}/${FirestoreCollections.cropImages}';

  static String userCropImage(String userId, String imageId) =>
      '${userCropImages(userId)}/$imageId';

  static String marketPrice(String priceId) =>
      '${FirestoreCollections.marketPrices}/$priceId';

  static String scheme(String schemeId) =>
      '${FirestoreCollections.schemes}/$schemeId';

  static String knowledgeBaseEntry(String entryId) =>
      '${FirestoreCollections.knowledgeBase}/$entryId';
}
