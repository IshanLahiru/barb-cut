import 'package:shared_preferences/shared_preferences.dart';
import '../core/di/service_locator.dart';

class OnboardingService {
  static const String _questionnaireCompletedKey =
      'onboarding_questionnaire_completed';
  static const String _homeWelcomeSwipeSeenKey = 'home_welcome_swipe_seen';

  Future<bool> isQuestionnaireCompleted() async {
    final prefs = getIt<SharedPreferences>();
    return prefs.getBool(_questionnaireCompletedKey) ?? false;
  }

  Future<void> markQuestionnaireCompleted() async {
    final prefs = getIt<SharedPreferences>();
    await prefs.setBool(_questionnaireCompletedKey, true);
  }

  Future<void> resetQuestionnaireCompletion() async {
    final prefs = getIt<SharedPreferences>();
    await prefs.setBool(_questionnaireCompletedKey, false);
  }

  /// Whether the user has seen the home "Swipe Up" welcome guide (first-run overlay).
  bool get homeWelcomeSwipeSeen {
    final prefs = getIt<SharedPreferences>();
    return prefs.getBool(_homeWelcomeSwipeSeenKey) ?? false;
  }

  Future<void> markHomeWelcomeSwipeSeen() async {
    final prefs = getIt<SharedPreferences>();
    await prefs.setBool(_homeWelcomeSwipeSeenKey, true);
  }
}
