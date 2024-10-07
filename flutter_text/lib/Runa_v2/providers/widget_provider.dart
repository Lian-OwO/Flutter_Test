import 'package:flutter/material.dart';
import '../models/widget_data.dart';
import 'package:flutter/foundation.dart';

/// WidgetProvider 클래스: 위젯 상태 관리 및 조작을 담당
class WidgetProvider extends ChangeNotifier {
  List<WidgetData> _widgets = [];
  WidgetData? _selectedWidget;
  bool _showCode = false;
  String? _draggingWidgetId;
  Offset? _dragStartPosition;

  // 페이지 속성 추가
  bool _safeArea = true;
  Color _backgroundColor = Colors.white;
  bool _showNavBar = true;

  // Getters
  List<WidgetData> get widgets => _widgets;
  WidgetData? get selectedWidget => _selectedWidget;
  bool get showCode => _showCode;
  bool get safeArea => _safeArea;
  Color get backgroundColor => _backgroundColor;
  bool get showNavBar => _showNavBar;

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
      print('WidgetProvider: 위젯선택 (${_selectedWidget!.type}) uuid - $id');
      notifyListeners();
    } catch (e) {
      print('WidgetProvider: 위젯을 찾을 수 없음 - $id');
      _selectedWidget = null;
      notifyListeners();
    }
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

  void updateWidgetPosition(String id, Offset newPosition) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      // 기존 위젯을 찾아서 위치만 업데이트하고, UUID를 변경하지 않음
      _widgets[index] = _widgets[index].copyWith(position: newPosition);
      notifyListeners();
    } else {
      print('Widget with id $id not found, cannot update position.');
    }
  }

  /// 코드에서 위젯 업데이트
  void updateWidgetsFromCode(List<WidgetData> newWidgets) {
    print("Updating widgets from code. New widgets: ${newWidgets.length}");

    for (var newWidget in newWidgets) {
      int index = _widgets.indexWhere((w) => w.id == newWidget.id);
      if (index != -1) {
        _widgets[index] = _widgets[index].copyWith(
          position: newWidget.position,
          width: newWidget.width,
          height: newWidget.height,
          color: newWidget.color,
          text: newWidget.text,
          fontSize: newWidget.fontSize,
          textColor: newWidget.textColor,
          isBold: newWidget.isBold,
          isItalic: newWidget.isItalic,
          fontFamily: newWidget.fontFamily,
        );
        print("Updated existing widget - ID: ${newWidget.id}, Text: ${newWidget.text}, Font Family: ${newWidget.fontFamily}");
      } else {
        _widgets.add(newWidget);
        print("Added new widget - ID: ${newWidget.id}, Text: ${newWidget.text}, Font Family: ${newWidget.fontFamily}");
      }
    }

    // 선택된 위젯 업데이트
    if (_selectedWidget != null) {
      _selectedWidget = _widgets.firstWhere(
            (w) => w.id == _selectedWidget!.id,
        orElse: () => _selectedWidget!,
      );
    }

    notifyListeners();
    print("업데이트 완료. 총 위젯 수 : ${_widgets.length}");
  }

  /// 위젯 삭제
  void removeWidget(String id) {
    _widgets.removeWhere((widget) => widget.id == id);
    if (_selectedWidget?.id == id) {
      _selectedWidget = null;
    }
    notifyListeners();
    print('WidgetProvider: 위젯삭제 uuid - $id');
  }

  ValueNotifier<double> getWidthListenable(String id) {
    try {
      return ValueNotifier<double>(_widgets.firstWhere((w) => w.id == id).width);
    } catch (e) {
      print('Widget with id $id not found. Returning default width.');
      return ValueNotifier<double>(100.0); // 기본 너비 값
    }
  }

  ValueNotifier<double> getHeightListenable(String id) {
    try {
      return ValueNotifier<double>(_widgets.firstWhere((w) => w.id == id).height);
    } catch (e) {
      print('Widget with id $id not found. Returning default height.');
      return ValueNotifier<double>(50.0); // 기본 높이 값
    }
  }

  ValueNotifier<String> getTextListenable(String id) {
    try {
      return ValueNotifier<String>(_widgets.firstWhere((w) => w.id == id).text ?? '');
    } catch (e) {
      print('Widget with id $id not found. Returning empty string.');
      return ValueNotifier<String>('');
    }
  }

  ValueNotifier<Color> getColorListenable(String id) {
    try {
      return ValueNotifier<Color>(_widgets.firstWhere((w) => w.id == id).color);
    } catch (e) {
      print('Widget with id $id not found. Returning default color.');
      return ValueNotifier<Color>(Colors.blue); // 기본 색상 값
    }
  }

  ValueListenable<double> getFontSizeListenable(String id) {
    final widget = _widgets.firstWhere((w) => w.id == id);
    return ValueNotifier<double>(widget.fontSize ?? 14.0);
  }

  ValueListenable<Color> getTextColorListenable(String id) {
    return ValueNotifier<Color>(_widgets.firstWhere((w) => w.id == id).textColor);
  }

  void updateWidgetFontSize(String id, double fontSize) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      _widgets[index] = _widgets[index].copyWith(fontSize: fontSize);
      _selectedWidget = _widgets[index];
      notifyListeners();
      print('WidgetProvider: 폰트 크기 업데이트 uuid - $id, FontSize: $fontSize');
    }
  }

  WidgetProvider() {
    _initializeFontSizes();
  }

  void _initializeFontSizes() {
    for (int i = 0; i < _widgets.length; i++) {
      if (_widgets[i].fontSize == null) {
        _widgets[i] = _widgets[i].copyWith(fontSize: 14.0);
      }
    }
  }


  void updateWidgetTextColor(String id, Color color) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      _widgets[index] = _widgets[index].copyWith(textColor: color);
      _selectedWidget = _widgets[index];
      notifyListeners();
      print('WidgetProvider: 텍스트 색상 업데이트 uuid - $id, TextColor: $color');
    }
  }

  void updateWidgetBold(String id, bool isBold) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      _widgets[index] = _widgets[index].copyWith(isBold: isBold);
      notifyListeners();
    }
  }

  void updateWidgetItalic(String id, bool isItalic) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      _widgets[index] = _widgets[index].copyWith(isItalic: isItalic);
      notifyListeners();
    }
  }
  void updateWidgetFontFamily(String id, String fontFamily) {
    final index = _widgets.indexWhere((widget) => widget.id == id);
    if (index != -1) {
      _widgets[index] = _widgets[index].copyWith(fontFamily: fontFamily);
      _selectedWidget = _widgets[index];
      notifyListeners();
      print('WidgetProvider: 폰트 패밀리 업데이트 uuid - $id, FontFamily: $fontFamily');
    }
  }



  // 페이지 속성 관리 메서드

  /// SafeArea 설정 토글
  void toggleSafeArea(bool value) {
    _safeArea = value;
    notifyListeners();
  }

  /// BackgroundColor 변경
  void changeBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  /// Navigation Bar 가시성 토글
  void toggleNavBar(bool value) {
    _showNavBar = value;
    notifyListeners();
  }

  /// 선택된 위젯 해제
  void clearSelectedWidget() {
    _selectedWidget = null;
    notifyListeners();
  }

  /// 코드로부터 기존 위젯만 업데이트
  void updateExistingWidgetsFromCode(List<WidgetData> updatedWidgets) {
    for (var updatedWidget in updatedWidgets) {
      final index = _widgets.indexWhere((w) => w.id == updatedWidget.id);
      if (index != -1) {
        // 기존 위젯 업데이트
        _widgets[index] = _widgets[index].copyWith(
          text: updatedWidget.text,
          color: updatedWidget.color,
          width: updatedWidget.width,
          height: updatedWidget.height,
          // position은 유지
        );
      }
      // 새 위젯은 추가하지 않음
    }

    // 선택된 위젯 업데이트
    if (_selectedWidget != null) {
      _selectedWidget = _widgets.firstWhere(
            (w) => w.id == _selectedWidget!.id,
        orElse: () => _selectedWidget!, // 선택된 위젯이 없어졌다면 그대로 유지
      );
    }

    notifyListeners();
  }

  /// 위젯 설정 (기존 메서드 유지)
  void setWidgets(List<WidgetData> newWidgets) {
    for (var newWidget in newWidgets) {
      final existingIndex = _widgets.indexWhere((widget) => widget.id == newWidget.id);

      if (existingIndex != -1) {
        // 기존 위젯이 있으면 속성만 업데이트
        print('기존 위젯 업데이트: ${newWidget.id}');
        _widgets[existingIndex] = _widgets[existingIndex].copyWith(
          position: newWidget.position,
          width: newWidget.width,
          height: newWidget.height,
          color: newWidget.color,
          text: newWidget.text,
        );
      } else {
        // 새로운 위젯은 추가하지 않음
        print('새 위젯 추가 시도 무시: ${newWidget.id}');
      }
    }
    notifyListeners();  // 상태 변경 알림
  }
}