import 'package:flutter/material.dart';
import '../models/widget_data.dart';

class WidgetProvider extends ChangeNotifier {
  List<WidgetData> _widgets = [];
  WidgetData? _selectedWidget;
  bool _isPanelVisible = true;  // 패널 가시성 상태
  bool _showCode = false;       // 코드 보기/미리보기 전환 상태

  List<WidgetData> get widgets => _widgets;
  WidgetData? get selectedWidget => _selectedWidget;
  bool get isPanelVisible => _isPanelVisible;
  bool get showCode => _showCode;

  // 고유 ID를 가진 새 위젯 추가
  void addWidget(WidgetData widget) {
    _widgets.add(widget);
    notifyListeners();  // 상태 변경 후 리스너에게 알림
  }

  // 고유 ID를 기반으로 위젯 선택 (패널 가시성 설정)
  void selectWidget(String id) {
    _selectedWidget = _widgets.firstWhere((widget) => widget.id == id);
    _isPanelVisible = true;  // 선택 시 패널 가시성 true
    notifyListeners();
  }

  // 패널 가시성 토글
  void togglePanelVisibility() {
    _isPanelVisible = !_isPanelVisible;
    notifyListeners();
  }

  // 코드/미리보기 전환
  void toggleView() {
    _showCode = !_showCode;
    notifyListeners();
  }

  // **위젯 위치 업데이트**
  void updateWidgetPosition(String id, Offset newPosition) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      _widgets[index] = _widgets[index].copyWith(position: newPosition);
      notifyListeners();  // 변경 사항을 알림
    }
  }

  // 위젯 크기 업데이트 (위치와 별도로)

  void updateWidgetSize(String id, {double? newWidth, double? newHeight}) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      final currentWidget = _widgets[index];
      _widgets[index] = currentWidget.copyWith(
        width: newWidth ?? currentWidget.width,
        height: newHeight ?? currentWidget.height,
      );
      notifyListeners();  // 위젯 변경 사항 알림
    }
  }

  // 위젯 색상 업데이트
  void updateWidgetColor(String id, Color newColor) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      _widgets[index] = _widgets[index].copyWith(color: newColor);
      notifyListeners();  // 상태 변경 후 리스너에게 알림
    }
  }


  // 선택한 위젯 삭제
  void removeWidget(String id) {
    _widgets.removeWhere((widget) => widget.id == id);
    if (_selectedWidget?.id == id) {
      _selectedWidget = null;
      _isPanelVisible = false;  // 위젯 삭제 시 패널 닫기
    }
    notifyListeners();
  }
}
