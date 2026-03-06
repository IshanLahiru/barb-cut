import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AiGenerationService {
  AiGenerationService._();

  static final FirebaseFunctions _functions = FirebaseFunctions.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new parent generation job with child jobs for each angle
  static Future<String> createGenerationJob({
    String? haircutId,
    String? beardId,
    List<String>? angles,
  }) async {
    try {
      final callable = _functions.httpsCallable('createGenerationJob');
      final result = await callable.call({
        'haircutId': haircutId,
        'beardId': beardId,
        'angles': angles,
      });

      final data = result.data as Map<dynamic, dynamic>;
      return data['parentJobId']?.toString() ?? '';
    } catch (e) {
      print('Error creating generation job: $e');
      rethrow;
    }
  }

  /// Listen to parent job status and all child jobs
  static Stream<GenerationJobStatus> watchGenerationJob(String parentJobId) {
    return _firestore
        .collection('aiJobs')
        .doc(parentJobId)
        .snapshots()
        .asyncExpand((parentSnap) async* {
          if (!parentSnap.exists) {
            return; // Parent deleted (moved to history)
          }

          final parentData = parentSnap.data() as Map<String, dynamic>;

          // Listen to all child jobs
          final childJobsSnap = await _firestore
              .collection('aiJobs')
              .doc(parentJobId)
              .collection('childJobs')
              .get();

          final childJobs = <AngleJobStatus>[];
          for (final childSnap in childJobsSnap.docs) {
            final childData = childSnap.data();
            childJobs.add(
              AngleJobStatus(
                angle: childData['angle'],
                status: childData['status'],
                referenceImage: childData['referenceImage'],
                generatedImage: childData['generatedImage'],
                errorMessage: childData['errorMessage'],
              ),
            );
          }

          yield GenerationJobStatus(
            parentJobId: parentJobId,
            status: parentData['status'],
            haircutName: parentData['haircutName'],
            beardName: parentData['beardName'],
            angleCount: parentData['angleCount'],
            childJobs: childJobs,
            createdAt: parentData['createdAt']?.toDate(),
          );
        });
  }

  /// Get completed job from history
  static Future<HistoryJob?> getHistoryJob(String parentJobId) async {
    try {
      final snap = await _firestore
          .collection('history')
          .where('parentJobId', isEqualTo: parentJobId)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return null;

      final data = snap.docs.first.data();
      return HistoryJob(
        historyId: snap.docs.first.id,
        parentJobId: data['parentJobId'],
        haircutName: data['haircutName'],
        beardName: data['beardName'],
        generatedImages: Map<String, String>.from(
          data['generatedImages'] as Map<String, dynamic>? ?? {},
        ),
        failedAngles: List<String>.from(data['failedAngles'] as List? ?? []),
        completedAt: data['completedAt']?.toDate(),
      );
    } catch (e) {
      print('Error fetching history job: $e');
      return null;
    }
  }

  /// Listen to all user history jobs
  static Stream<List<HistoryJob>> watchUserHistory(String userId) {
    return _firestore
        .collection('history')
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs.map((doc) {
            final data = doc.data();
            return HistoryJob(
              historyId: doc.id,
              parentJobId: data['parentJobId'],
              haircutName: data['haircutName'],
              beardName: data['beardName'],
              generatedImages: Map<String, String>.from(
                data['generatedImages'] as Map? ?? {},
              ),
              failedAngles: List<String>.from(
                data['failedAngles'] as List? ?? [],
              ),
              completedAt: data['completedAt']?.toDate(),
            );
          }).toList();
        });
  }

  /// Get actively generating job (if any)
  static Future<String?> getActiveGenerationJob(String userId) async {
    try {
      final snap = await _firestore
          .collection('aiJobs')
          .where('schemaVersion', isEqualTo: 2)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'generating')
          .limit(1)
          .get();

      return snap.docs.isNotEmpty ? snap.docs.first.id : null;
    } catch (e) {
      print('Error fetching active job: $e');
      return null;
    }
  }
}

// Models
class GenerationJobStatus {
  final String parentJobId;
  final String status;
  final String? haircutName;
  final String? beardName;
  final int angleCount;
  final List<AngleJobStatus> childJobs;
  final DateTime? createdAt;

  GenerationJobStatus({
    required this.parentJobId,
    required this.status,
    this.haircutName,
    this.beardName,
    required this.angleCount,
    required this.childJobs,
    this.createdAt,
  });

  bool get isGenerating => status == "generating";
  bool get isCompleted => status == "completed";
  bool get isError => status == "error";

  int get completedCount => childJobs.where((c) => c.isCompleted).length;
  int get failedCount => childJobs.where((c) => c.isError).length;
}

class AngleJobStatus {
  final String angle;
  final String status;
  final String? referenceImage;
  final String? generatedImage;
  final String? errorMessage;

  AngleJobStatus({
    required this.angle,
    required this.status,
    this.referenceImage,
    this.generatedImage,
    this.errorMessage,
  });

  bool get isPending => status == "pending";
  bool get isProcessing => status == "processing";
  bool get isCompleted => status == "completed";
  bool get isError => status == "error";

  String get displayAngle {
    switch (angle) {
      case "FRONT":
        return "Front";
      case "LEFT":
        return "Left";
      case "RIGHT":
        return "Right";
      case "BACK":
        return "Back";
      default:
        return angle;
    }
  }
}

class HistoryJob {
  final String historyId;
  final String parentJobId;
  final String? haircutName;
  final String? beardName;
  final Map<String, String> generatedImages;
  final List<String> failedAngles;
  final DateTime? completedAt;

  HistoryJob({
    required this.historyId,
    required this.parentJobId,
    this.haircutName,
    this.beardName,
    required this.generatedImages,
    required this.failedAngles,
    this.completedAt,
  });

  List<String> get successfulAngles {
    return [
      "FRONT",
      "LEFT",
      "RIGHT",
      "BACK",
    ].where((a) => generatedImages.containsKey(a.toLowerCase())).toList();
  }
}
