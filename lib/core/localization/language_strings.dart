import 'package:flutter/widgets.dart';

enum AppLanguage {
  english('en', 'English'),
  hindi('hi', 'Hindi'),
  marathi('mr', 'Marathi');

  const AppLanguage(this.code, this.label);

  final String code;
  final String label;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    return switch (code) {
      'hi' => AppLanguage.hindi,
      'mr' => AppLanguage.marathi,
      _ => AppLanguage.english,
    };
  }
}

class LanguageStrings {
  const LanguageStrings(this.language);

  final AppLanguage language;

  String get appName => 'AgriGuide AI';
  String get appTagline => _pick(
        en: 'AI-powered agriculture intelligence companion',
        hi: 'AI आधारित कृषि बुद्धिमान साथी',
        mr: 'AI आधारित शेती बुद्धिमान साथी',
      );

  String get chooseLanguage => _pick(
        en: 'Choose language',
        hi: 'भाषा चुनें',
        mr: 'भाषा निवडा',
      );
  String get continueText =>
      _pick(en: 'Continue', hi: 'जारी रखें', mr: 'पुढे जा');
  String get getStarted =>
      _pick(en: 'Get Started', hi: 'शुरू करें', mr: 'सुरू करा');
  String get signIn =>
      _pick(en: 'Sign In', hi: 'साइन इन करें', mr: 'साइन इन करा');
  String get register =>
      _pick(en: 'Register', hi: 'रजिस्टर करें', mr: 'नोंदणी करा');
  String get createAccount =>
      _pick(en: 'Create Account', hi: 'खाता बनाएं', mr: 'खाते तयार करा');
  String get forgotPassword =>
      _pick(en: 'Forgot Password', hi: 'पासवर्ड भूल गए', mr: 'पासवर्ड विसरलात');
  String get email => _pick(en: 'Email', hi: 'ईमेल', mr: 'ईमेल');
  String get password => _pick(en: 'Password', hi: 'पासवर्ड', mr: 'पासवर्ड');
  String get fullName =>
      _pick(en: 'Full Name', hi: 'पूरा नाम', mr: 'पूर्ण नाव');
  String get mobileNumber =>
      _pick(en: 'Mobile Number', hi: 'मोबाइल नंबर', mr: 'मोबाइल नंबर');
  String get farmerProfile =>
      _pick(en: 'Farmer Profile', hi: 'किसान प्रोफाइल', mr: 'शेतकरी प्रोफाइल');
  String get profileSetup =>
      _pick(en: 'Profile Setup', hi: 'प्रोफाइल सेटअप', mr: 'प्रोफाइल सेटअप');
  String get saveProfile => _pick(
        en: 'Save Profile',
        hi: 'प्रोफाइल सेव करें',
        mr: 'प्रोफाइल सेव करा',
      );
  String get farmerDetails =>
      _pick(en: 'Farmer details', hi: 'किसान विवरण', mr: 'शेतकरी तपशील');
  String get location => _pick(en: 'Location', hi: 'स्थान', mr: 'स्थान');
  String get farmProfile =>
      _pick(en: 'Farm profile', hi: 'खेत प्रोफाइल', mr: 'शेत प्रोफाइल');
  String get village => _pick(en: 'Village', hi: 'गांव', mr: 'गाव');
  String get taluka => _pick(en: 'Taluka', hi: 'तालुका', mr: 'तालुका');
  String get district => _pick(en: 'District', hi: 'जिला', mr: 'जिल्हा');
  String get state => _pick(en: 'State', hi: 'राज्य', mr: 'राज्य');
  String get farmSize =>
      _pick(en: 'Farm Size', hi: 'खेत का आकार', mr: 'शेताचा आकार');
  String get soilType =>
      _pick(en: 'Soil Type', hi: 'मिट्टी का प्रकार', mr: 'मातीचा प्रकार');
  String get irrigationMethod =>
      _pick(en: 'Irrigation Method', hi: 'सिंचाई विधि', mr: 'सिंचन पद्धत');
  String get waterSource =>
      _pick(en: 'Water Source', hi: 'जल स्रोत', mr: 'पाण्याचा स्रोत');
  String get profilePhotoUrl => _pick(
        en: 'Profile Photo URL',
        hi: 'प्रोफाइल फोटो URL',
        mr: 'प्रोफाइल फोटो URL',
      );
  String get dashboard =>
      _pick(en: 'Dashboard', hi: 'डैशबोर्ड', mr: 'डॅशबोर्ड');
  String get farmOverview =>
      _pick(en: 'Farm overview', hi: 'खेत सारांश', mr: 'शेत सारांश');
  String activeCropsCount(int count) => _pick(
        en: '$count active crop${count == 1 ? '' : 's'} under management',
        hi: '$count सक्रिय फसल प्रबंधन में',
        mr: '$count सक्रिय पीक व्यवस्थापनात',
      );
  String get addCrop => _pick(en: 'Add Crop', hi: 'फसल जोड़ें', mr: 'पीक जोडा');
  String get viewCrops =>
      _pick(en: 'View Crops', hi: 'फसलें देखें', mr: 'पिके पहा');
  String get activeCrops =>
      _pick(en: 'Active Crops', hi: 'सक्रिय फसलें', mr: 'सक्रिय पिके');
  String get noUserDashboard => _pick(
        en: 'Please sign in to view dashboard.',
        hi: 'डैशबोर्ड देखने के लिए साइन इन करें।',
        mr: 'डॅशबोर्ड पाहण्यासाठी साइन इन करा.',
      );
  String get addCropToStart => _pick(
        en: 'Add a crop to start tracking stage progress and farm activities.',
        hi: 'फसल की अवस्था और खेती गतिविधियों को ट्रैक करने के लिए फसल जोड़ें।',
        mr: 'पीक अवस्था आणि शेती कामे पाहण्यासाठी पीक जोडा.',
      );
  String get agriGuideAi =>
      _pick(en: 'AgriGuide AI', hi: 'AgriGuide AI', mr: 'AgriGuide AI');
  String get diseaseDetection =>
      _pick(en: 'Disease detection', hi: 'रोग पहचान', mr: 'रोग ओळख');
  String get farmerProfileTooltip =>
      _pick(en: 'Farmer profile', hi: 'किसान प्रोफाइल', mr: 'शेतकरी प्रोफाइल');
  String get weatherAdvisory => _pick(
        en: 'Weather Advisory',
        hi: 'मौसम सलाह',
        mr: 'हवामान सल्ला',
      );
  String get fertilizerAdvisory => _pick(
        en: 'Fertilizer Advisory',
        hi: 'उर्वरक सलाह',
        mr: 'खत सल्ला',
      );
  String get irrigationAdvisory => _pick(
        en: 'Irrigation Advisory',
        hi: 'सिंचाई सलाह',
        mr: 'सिंचन सल्ला',
      );
  String get retry =>
      _pick(en: 'Retry', hi: 'फिर कोशिश करें', mr: 'पुन्हा प्रयत्न करा');
  String get refresh =>
      _pick(en: 'Refresh', hi: 'रीफ्रेश करें', mr: 'रीफ्रेश करा');
  String get noActiveCrop => _pick(
        en: 'Add an active crop to generate this recommendation.',
        hi: 'यह सलाह बनाने के लिए सक्रिय फसल जोड़ें।',
        mr: 'हा सल्ला तयार करण्यासाठी सक्रिय पीक जोडा.',
      );
  String get currentWeather => _pick(
        en: 'Current Weather',
        hi: 'वर्तमान मौसम',
        mr: 'सध्याचे हवामान',
      );
  String get sevenDayForecast => _pick(
        en: '7-Day Forecast',
        hi: '7 दिन का पूर्वानुमान',
        mr: '7 दिवसांचा अंदाज',
      );
  String get weatherAlerts => _pick(
        en: 'Weather Alerts',
        hi: 'मौसम अलर्ट',
        mr: 'हवामान सूचना',
      );
  String get aiWeatherRecommendation => _pick(
        en: 'AI Weather Recommendation',
        hi: 'AI मौसम सिफारिश',
        mr: 'AI हवामान शिफारस',
      );
  String get weatherSummary => _pick(
        en: 'Weather Summary',
        hi: 'मौसम सारांश',
        mr: 'हवामान सारांश',
      );
  String get possibleImpact => _pick(
        en: 'Possible Impact',
        hi: 'संभावित प्रभाव',
        mr: 'संभाव्य परिणाम',
      );
  String get suggestedAction => _pick(
        en: 'Suggested Action',
        hi: 'सुझाया गया कार्य',
        mr: 'सुचवलेली कृती',
      );
  String get preventiveMeasures => _pick(
        en: 'Preventive Measures',
        hi: 'बचाव उपाय',
        mr: 'प्रतिबंधक उपाय',
      );
  String get forecast => _pick(en: 'Forecast', hi: 'पूर्वानुमान', mr: 'अंदाज');
  String get temperature =>
      _pick(en: 'Temperature', hi: 'तापमान', mr: 'तापमान');
  String get humidity => _pick(en: 'Humidity', hi: 'नमी', mr: 'आर्द्रता');
  String get windSpeed =>
      _pick(en: 'Wind Speed', hi: 'हवा की गति', mr: 'वाऱ्याचा वेग');
  String get rainProbability => _pick(
        en: 'Rain Probability',
        hi: 'बारिश की संभावना',
        mr: 'पावसाची शक्यता',
      );
  String get sunrise => _pick(en: 'Sunrise', hi: 'सूर्योदय', mr: 'सूर्योदय');
  String get sunset => _pick(en: 'Sunset', hi: 'सूर्यास्त', mr: 'सूर्यास्त');
  String get fertilizerSummary => _pick(
        en: 'Fertilizer Summary',
        hi: 'उर्वरक सारांश',
        mr: 'खत सारांश',
      );
  String get applicationSchedule => _pick(
        en: 'Application Schedule',
        hi: 'प्रयोग कार्यक्रम',
        mr: 'वापर वेळापत्रक',
      );
  String get nutrientRequirement => _pick(
        en: 'Nutrient Requirement',
        hi: 'पोषक आवश्यकता',
        mr: 'पोषक गरज',
      );
  String get recommendedFertilizer => _pick(
        en: 'Recommended fertilizer',
        hi: 'सुझाया गया उर्वरक',
        mr: 'सुचवलेले खत',
      );
  String get quantity => _pick(en: 'Quantity', hi: 'मात्रा', mr: 'प्रमाण');
  String get applicationTiming => _pick(
        en: 'Application timing',
        hi: 'प्रयोग समय',
        mr: 'वापराची वेळ',
      );
  String get precautions =>
      _pick(en: 'Precautions', hi: 'सावधानियां', mr: 'काळजी');
  String get waterRequirement => _pick(
        en: 'Water Requirement',
        hi: 'जल आवश्यकता',
        mr: 'पाण्याची गरज',
      );
  String get irrigationSchedule => _pick(
        en: 'Irrigation Schedule',
        hi: 'सिंचाई कार्यक्रम',
        mr: 'सिंचन वेळापत्रक',
      );
  String get irrigationAlerts => _pick(
        en: 'Irrigation Alerts',
        hi: 'सिंचाई अलर्ट',
        mr: 'सिंचन सूचना',
      );
  String get irrigationFrequency => _pick(
        en: 'Irrigation frequency',
        hi: 'सिंचाई आवृत्ति',
        mr: 'सिंचन वारंवारता',
      );
  String get nextIrrigationDate => _pick(
        en: 'Next irrigation date',
        hi: 'अगली सिंचाई तिथि',
        mr: 'पुढील सिंचन तारीख',
      );
  String get advisoryNotes => _pick(
        en: 'Advisory notes',
        hi: 'सलाह नोट्स',
        mr: 'सल्ला नोंदी',
      );
  String get marketPrices =>
      _pick(en: 'Market Prices', hi: 'मंडी भाव', mr: 'बाजार भाव');
  String get governmentSchemes =>
      _pick(en: 'Government Schemes', hi: 'सरकारी योजनाएं', mr: 'शासकीय योजना');
  String get reminders =>
      _pick(en: 'Reminders', hi: 'रिमाइंडर', mr: 'स्मरणपत्रे');
  String get notifications =>
      _pick(en: 'Notifications', hi: 'सूचनाएं', mr: 'सूचना');
  String get farmHistory =>
      _pick(en: 'Farm History', hi: 'खेती इतिहास', mr: 'शेती इतिहास');
  String get searchCrop =>
      _pick(en: 'Search crop', hi: 'फसल खोजें', mr: 'पीक शोधा');
  String get marketName => _pick(en: 'Market', hi: 'मंडी', mr: 'बाजार');
  String get minimumPrice =>
      _pick(en: 'Minimum price', hi: 'न्यूनतम भाव', mr: 'किमान भाव');
  String get maximumPrice =>
      _pick(en: 'Maximum price', hi: 'अधिकतम भाव', mr: 'कमाल भाव');
  String get averagePrice =>
      _pick(en: 'Average price', hi: 'औसत भाव', mr: 'सरासरी भाव');
  String get priceTrend =>
      _pick(en: 'Price trend', hi: 'भाव रुझान', mr: 'भाव कल');
  String get sellingSuggestion =>
      _pick(en: 'Selling suggestion', hi: 'बिक्री सलाह', mr: 'विक्री सल्ला');
  String get schemeRecommendation => _pick(
        en: 'Scheme recommendation',
        hi: 'योजना सिफारिश',
        mr: 'योजना शिफारस',
      );
  String get eligibility =>
      _pick(en: 'Eligibility', hi: 'पात्रता', mr: 'पात्रता');
  String get benefits => _pick(en: 'Benefits', hi: 'लाभ', mr: 'लाभ');
  String get requiredDocuments => _pick(
        en: 'Required documents',
        hi: 'आवश्यक दस्तावेज',
        mr: 'आवश्यक कागदपत्रे',
      );
  String get applicationProcess => _pick(
        en: 'Application process',
        hi: 'आवेदन प्रक्रिया',
        mr: 'अर्ज प्रक्रिया',
      );
  String get deadline =>
      _pick(en: 'Deadline', hi: 'अंतिम तिथि', mr: 'अंतिम तारीख');
  String get addReminder =>
      _pick(en: 'Add Reminder', hi: 'रिमाइंडर जोड़ें', mr: 'स्मरणपत्र जोडा');
  String get editReminder => _pick(
        en: 'Edit Reminder',
        hi: 'रिमाइंडर संपादित करें',
        mr: 'स्मरणपत्र संपादित करा',
      );
  String get reminderType =>
      _pick(en: 'Reminder type', hi: 'रिमाइंडर प्रकार', mr: 'स्मरणपत्र प्रकार');
  String get dueDate => _pick(en: 'Due date', hi: 'देय तिथि', mr: 'देय तारीख');
  String get priority =>
      _pick(en: 'Priority', hi: 'प्राथमिकता', mr: 'प्राधान्य');
  String get status => _pick(en: 'Status', hi: 'स्थिति', mr: 'स्थिती');
  String get save => _pick(en: 'Save', hi: 'सेव करें', mr: 'सेव करा');
  String get delete => _pick(en: 'Delete', hi: 'हटाएं', mr: 'हटवा');
  String get markCompleted => _pick(
        en: 'Mark completed',
        hi: 'पूरा चिह्नित करें',
        mr: 'पूर्ण चिन्हांकित करा',
      );
  String get snooze =>
      _pick(en: 'Snooze', hi: 'बाद में याद दिलाएं', mr: 'नंतर आठवण');
  String get markRead =>
      _pick(en: 'Mark read', hi: 'पढ़ा हुआ करें', mr: 'वाचलेले करा');
  String get filter => _pick(en: 'Filter', hi: 'फिल्टर', mr: 'फिल्टर');
  String get title => _pick(en: 'Title', hi: 'शीर्षक', mr: 'शीर्षक');
  String get description => _pick(en: 'Description', hi: 'विवरण', mr: 'वर्णन');
  String get type => _pick(en: 'Type', hi: 'प्रकार', mr: 'प्रकार');
  String get noData => _pick(
        en: 'No records found.',
        hi: 'कोई रिकॉर्ड नहीं मिला।',
        mr: 'नोंदी सापडल्या नाहीत.',
      );
  String get openDetails =>
      _pick(en: 'Open details', hi: 'विवरण खोलें', mr: 'तपशील उघडा');

  String get cropCalendar =>
      _pick(en: 'Crop Calendar', hi: 'फसल कैलेंडर', mr: 'पीक कॅलेंडर');
  String get farmActivities =>
      _pick(en: 'Farm Activities', hi: 'खेती गतिविधियां', mr: 'शेती उपक्रम');
  String get cropGallery =>
      _pick(en: 'Crop Gallery', hi: 'फसल गैलरी', mr: 'पीक गॅलरी');
  String get uploadImage =>
      _pick(en: 'Upload Image', hi: 'छवि अपलोड करें', mr: 'चित्र अपलोड करा');
  String get cropStage =>
      _pick(en: 'Crop Stage', hi: 'फसल अवस्था', mr: 'पीक अवस्था');
  String get weatherRisk =>
      _pick(en: 'Weather risk', hi: 'मौसम जोखिम', mr: 'हवामान धोका');
  String get marketOpportunity =>
      _pick(en: 'Market opportunity', hi: 'बाजार अवसर', mr: 'बाजार संधी');
  String get diseaseRisk =>
      _pick(en: 'Disease risk', hi: 'रोग जोखिम', mr: 'रोग धोका');

  String _pick({
    required String en,
    required String hi,
    required String mr,
  }) {
    return switch (language) {
      AppLanguage.hindi => hi,
      AppLanguage.marathi => mr,
      AppLanguage.english => en,
    };
  }
}
