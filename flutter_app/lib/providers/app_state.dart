import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/weight_config.dart';
import '../models/user_profile.dart';

class AppState extends ChangeNotifier {
  bool _darkMode = false;
  int _currentTab = 0;
  WeightConfig _weightConfig = WeightConfig();
  UserProfile _userProfile = UserProfile();

  bool get darkMode => _darkMode;
  int get currentTab => _currentTab;
  WeightConfig get weightConfig => _weightConfig;
  UserProfile get userProfile => _userProfile;

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    _userProfile = _userProfile.copyWith(darkMode: _darkMode ? 1 : 0);
    DatabaseHelper.instance.updateUserProfile(_userProfile);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _darkMode = value;
    _userProfile = _userProfile.copyWith(darkMode: value ? 1 : 0);
    DatabaseHelper.instance.updateUserProfile(_userProfile);
    notifyListeners();
  }

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  Future<void> loadWeights() async {
    _weightConfig = await DatabaseHelper.instance.getWeightConfig();
    notifyListeners();
  }

  Future<void> updateWeights(WeightConfig config) async {
    await DatabaseHelper.instance.updateWeightConfig(config);
    _weightConfig = config;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    _userProfile = await DatabaseHelper.instance.getUserProfile();
    _darkMode = _userProfile.darkMode == 1;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    await DatabaseHelper.instance.updateUserProfile(profile);
    _userProfile = profile;
    _darkMode = profile.darkMode == 1;
    notifyListeners();
  }
}

// 品鉴表单状态管理
class TastingFormState {
  String wineType = 'red';
  bool isBlind = false;
  String scoringMode = 'standard';

  // 酒款信息
  String wineName = '';
  String winery = '';
  String country = '';
  String region = '';
  String variety = '';
  int? vintage;
  double? alcohol;
  double? price;
  DateTime? purchaseDate;
  DateTime? drinkingDate;
  String venue = '';

  // 外观
  String? appearanceColor;
  String? clarity;
  String? intensity;
  String? condition;
  String? tears;
  String? bubbleFineness;
  String? bubblePersistence;

  // 香气
  int aromaIntensity = 0;
  int aromaComplexity = 0;
  int aromaPurity = 0;
  int aromaPersistence = 0;
  String? development;

  // 口感
  int acidity = 0;
  int tannin = 0;
  String? tanninTexture;
  int body = 0;
  int balance = 0;
  int palateComplexity = 0;
  int finishLength = 0;
  String? finishCharacter;
  int? alcoholPerception;

  // 综合
  int typicality = 0;
  int enjoyment = 0;
  int value = 0;
  int agingPotential = 0;
  String? agingAdvice;
  int repurchase = 0;

  // 风味词
  List<int> selectedFlavorIds = [];
  String customNote = '';
}

class TastingProvider extends ChangeNotifier {
  TastingFormState _state = TastingFormState();

  TastingFormState get state => _state;

  void resetForm({String? wineType}) {
    _state = TastingFormState();
    if (wineType != null) {
      _state.wineType = wineType;
    }
    notifyListeners();
  }

  void setWineType(String type) {
    _state.wineType = type;
    notifyListeners();
  }

  void setBlind(bool value) {
    _state.isBlind = value;
    notifyListeners();
  }

  void setScoringMode(String mode) {
    _state.scoringMode = mode;
    notifyListeners();
  }

  void setWineName(String value) {
    _state.wineName = value;
    notifyListeners();
  }

  void setWinery(String value) {
    _state.winery = value;
    notifyListeners();
  }

  void setCountry(String value) {
    _state.country = value;
    notifyListeners();
  }

  void setRegion(String value) {
    _state.region = value;
    notifyListeners();
  }

  void setVariety(String value) {
    _state.variety = value;
    notifyListeners();
  }

  void setVintage(int? value) {
    _state.vintage = value;
    notifyListeners();
  }

  void setAlcohol(double? value) {
    _state.alcohol = value;
    notifyListeners();
  }

  void setPrice(double? value) {
    _state.price = value;
    notifyListeners();
  }

  void setPurchaseDate(DateTime? value) {
    _state.purchaseDate = value;
    notifyListeners();
  }

  void setDrinkingDate(DateTime? value) {
    _state.drinkingDate = value;
    notifyListeners();
  }

  void setVenue(String value) {
    _state.venue = value;
    notifyListeners();
  }

  void update() {
    notifyListeners();
  }
}
