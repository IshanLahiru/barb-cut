import 'package:shared_preferences/shared_preferences.dart';
import '../core/di/service_locator.dart';

class OnboardingService {
  static const String _questionnaireCompletedKey =
      'onboarding_questionnaire_completed';

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
}
