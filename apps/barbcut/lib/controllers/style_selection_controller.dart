import 'package:flutter/foundation.dart';
import '../features/home/domain/entities/style_entity.dart';

class StyleSelectionController extends ChangeNotifier {
  StyleEntity? _selectedHaircutStyle;
  StyleEntity? _selectedBeardStyle;
  int _selectedAngleIndex = 0;
  bool _isDetailViewExpanded = false;

  StyleEntity? get selectedHaircutStyle => _selectedHaircutStyle;
  StyleEntity? get selectedBeardStyle => _selectedBeardStyle;
  int get selectedAngleIndex => _selectedAngleIndex;
  bool get isDetailViewExpanded => _isDetailViewExpanded;

  ImageAngle get currentAngle {
    switch (_selectedAngleIndex) {
      case 0:
        return ImageAngle.front;
      case 1:
        return ImageAngle.leftSide;
      case 2:
        return ImageAngle.rightSide;
      case 3:
        return ImageAngle.back;
      default:
        return ImageAngle.front;
    }
  }

  String? getCurrentImage() {
    if (_selectedHaircutStyle == null) return null;
    return _selectedHaircutStyle!.styleImages.getByAngle(currentAngle);
  }

  List<String> getAllAngles() {
    if (_selectedHaircutStyle == null) return [];
    return _selectedHaircutStyle!.styleImages.toList();
  }

  void selectHaircutStyle(StyleEntity style) {
    _selectedHaircutStyle = style;
    _selectedAngleIndex = 0; // Reset to front view
    notifyListeners();
  }

  void selectBeardStyle(StyleEntity style) {
    _selectedBeardStyle = style;
    notifyListeners();
  }

  void selectAngle(int index) {
    if (index >= 0 && index < 4) {
      _selectedAngleIndex = index;
      notifyListeners();
    }
  }

  void nextAngle() {
    _selectedAngleIndex = (_selectedAngleIndex + 1) % 4;
    notifyListeners();
  }

  void previousAngle() {
    _selectedAngleIndex = (_selectedAngleIndex - 1 + 4) % 4;
    notifyListeners();
  }

  void setDetailViewExpanded(bool expanded) {
    _isDetailViewExpanded = expanded;
    notifyListeners();
  }

  void clearSelection() {
    _selectedHaircutStyle = null;
    _selectedBeardStyle = null;
    _selectedAngleIndex = 0;
    _isDetailViewExpanded = false;
    notifyListeners();
  }
}
