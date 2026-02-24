import 'package:cloud_functions/cloud_functions.dart';

class AiGenerationService {
  AiGenerationService._();

  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static Future<String> createGenerationJob({
    String? haircutId,
    String? beardId,
    String? referenceImageUrl,
  }) async {
    final callable = _functions.httpsCallable('createGenerationJob');
    final result = await callable.call({
      'haircutId': haircutId,
      'beardId': beardId,
      'referenceImageUrl': referenceImageUrl,
    });

    final data = result.data as Map<dynamic, dynamic>;
    return data['jobId']?.toString() ?? '';
  }
}
