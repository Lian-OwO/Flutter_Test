import 'package:flutter/material.dart';
import '../models/widget_data.dart';

/// WidgetProvider 클래스: 위젯 상태 관리 및 조작을 담당
class WidgetProvider extends ChangeNotifier {
  List<WidgetData> _widgets = [];
  WidgetData? _selectedWidget;
  bool _isPanelVisible = false;
  bool _showCode = false;
  String? _draggingWidgetId;
  Offset? _dragStartPosition;

  // Getters
  List<WidgetData> get widgets => _widgets;
  WidgetData? get selectedWidget => _selectedWidget;
  bool get isPanelVisible => _isPanelVisible;
  bool get showCode => _showCode;

  /// 새 위젯 추가
  void addWidget(WidgetData widget) {
    _widgets.add(widget);
    selectWidget(widget.id);
    notifyListeners();
    print('WidgetProvider: 위젯추가(${widget.type}) uuid - ${widget.id}, Width: ${widget.width}, Height: ${widget.height}, Color: ${widget.color}, Text: ${widget.text}');
  }

  /// 위젯 선택
  void selectWidget(String id) {
    try {
      _selectedWidget = _widgets.firstWhere((widget) => widget.id == id);
      _isPanelVisible = true;
      print('WidgetProvider: 위젯선택 (${_selectedWidget!.type}) uuid - $id'); //로그출력
      notifyListeners();
    } catch(e) {
      print('WidgetProvider: 위젯을 찾을 수 없음 - $id');
      _selectedWidget = null;
      _isPanelVisible = false;
      notifyListeners();
    }
  }

  /// 패널 가시성 토글
  void togglePanelVisibility() {
    _isPanelVisible = !_isPanelVisible;
    if (!_isPanelVisible) {
      _selectedWidget = null;
    }
    notifyListeners();
  }

  /// 코드/미리보기 전환
  void toggleView() {
    _showCode = !_showCode;
    notifyListeners();
  }

  /// 드래그 시작
  void startDragging(String id) {
    _draggingWidgetId = id;
    _dragStartPosition = _widgets.firstWhere((w) => w.id == id).position;
  }

  /// 드래그 중 위치 업데이트 (로그 없이 UI만 업데이트)
  void updateWidgetPositionWhileDragging(String id, Offset newPosition) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      _widgets[index] = _widgets[index].copyWith(position: newPosition);
      if (_selectedWidget?.id == id) {
        _selectedWidget = _widgets[index];
      }
      notifyListeners();
    }
  }

  /// 드래그 종료 및 최종 위치 업데이트
  void endDragging() {
    if (_draggingWidgetId != null && _dragStartPosition != null) {
      final widget = _widgets.firstWhere((w) => w.id == _draggingWidgetId);
      final endPosition = widget.position;
      if (_dragStartPosition != endPosition) {
        print('WidgetProvider: 위치 업데이트 (${widget.type}) uuid - ${widget.id}, '
            'Start: (${_dragStartPosition!.dx}, ${_dragStartPosition!.dy}), '
            'End: (${endPosition.dx}, ${endPosition.dy})');
      }
    }
    _draggingWidgetId = null;
    _dragStartPosition = null;
  }

  /// 위젯 크기 업데이트
  void updateWidgetSize(String id, {double? newWidth, double? newHeight}) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      double updatedWidth = newWidth ?? _widgets[index].width;
      double updatedHeight = newHeight ?? _widgets[index].height;

      // 최소값 설정
      updatedWidth = updatedWidth.clamp(10.0, double.infinity);
      updatedHeight = updatedHeight.clamp(10.0, double.infinity);

      _widgets[index] = _widgets[index].copyWith(
        width: updatedWidth,
        height: updatedHeight,
      );

      // 선택된 위젯도 업데이트
      if (_selectedWidget?.id == id) {
        _selectedWidget = _widgets[index];
      }

      // ValueNotifier 업데이트
      getWidthListenable(id).value = updatedWidth;
      getHeightListenable(id).value = updatedHeight;

      print('WidgetProvider: 크기 업데이트 (${_widgets[index].type}) uuid - $id, Width: ${_widgets[index].width}, Height: ${_widgets[index].height}');
      notifyListeners();
    }
  }

  /// 위젯 색상 업데이트
  void updateWidgetColor(String id, Color newColor) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      _widgets[index] = _widgets[index].copyWith(color: newColor);
      _selectedWidget = _widgets[index];

      // ValueNotifier 업데이트
      getColorListenable(id).value = newColor;

      print('WidgetProvider: 색상 업데이트 (${_widgets[index].type}) uuid - $id, Color: $newColor');
      notifyListeners();
    }
  }

  /// 위젯 텍스트 업데이트
  void updateWidgetText(String id, String newText) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      _widgets[index] = _widgets[index].copyWith(text: newText);

      // ValueNotifier 업데이트
      getTextListenable(id).value = newText;

      print('WidgetProvider: 텍스트 업데이트 (${_widgets[index].type}) uuid - $id, Text: $newText');
      notifyListeners();
    }
  }

  /// 위젯 삭제
  void removeWidget(String id) {
    _widgets.removeWhere((widget) => widget.id == id);
    if (_selectedWidget?.id == id) {
      _selectedWidget = null;
      _isPanelVisible = false;
    }
    notifyListeners();
    print('WidgetProvider: 위젯삭제 uuid - $id');
  }

  /// 위젯 너비에 대한 ValueListenable 반환
  ValueNotifier<double> getWidthListenable(String id) {
    return ValueNotifier<double>(_widgets.firstWhere((w) => w.id == id).width);
  }

  /// 위젯 높이에 대한 ValueListenable 반환
  ValueNotifier<double> getHeightListenable(String id) {
    return ValueNotifier<double>(_widgets.firstWhere((w) => w.id == id).height);
  }

  /// 위젯 텍스트에 대한 ValueListenable 반환
  ValueNotifier<String> getTextListenable(String id) {
    return ValueNotifier<String>(_widgets.firstWhere((w) => w.id == id).text ?? '');
  }

  /// 위젯 색상에 대한 ValueListenable 반환
  ValueNotifier<Color> getColorListenable(String id) {
    return ValueNotifier<Color>(_widgets.firstWhere((w) => w.id == id).color);
  }
}