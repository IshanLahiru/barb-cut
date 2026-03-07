import 'package:equatable/equatable.dart';

class HistoryEntity extends Equatable {
  final String id;
  final String imageUrl;
  final String haircut;
  final String beard;
  final DateTime timestamp;

  const HistoryEntity({
    required this.id,
    required this.imageUrl,
    required this.haircut,
    required this.beard,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, imageUrl, haircut, beard, timestamp];
}
