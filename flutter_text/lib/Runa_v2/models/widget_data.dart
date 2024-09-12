import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// WidgetData 클래스: 위젯데이터 저장관리
class WidgetData {
  final String id;
  final String type;
  Offset position;
  Offset? _originalPosition;
  double width;
  double height;
  Color color;
  String text;

  /// 생성자
  WidgetData({
    String? id,
    required this.type,
    required this.position,
    Offset? originalPosition,
    required this.width,
    required this.height,
    required this.color,
    this.text = '',
  }) : id = id ?? const Uuid().v4() {
    // 초기 생성 시 원래 위치 설정
    _originalPosition = originalPosition ?? position;
  }

  /// originalPosition에 대한 getter
  /// 원래 위치가 null인 경우 현재 위치를 반환
  Offset get originalPosition => _originalPosition ?? position;

  /// WidgetData의 복사본을 생성하는 메서드
  WidgetData copyWith({
    String? id,
    String? type,
    Offset? position,
    Offset? originalPosition,
    double? width,
    double? height,
    Color? color,
    String? text,
  }) {
    return WidgetData(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      originalPosition: originalPosition ?? _originalPosition,
      width: width ?? this.width,
      height: height ?? this.height,
      color: color ?? this.color,
      text: text ?? this.text,
    );
  }

  /// 위젯의 Dart 코드 표현을 생성하는 메서드
  String toDartCode() {
    return '''
      Positioned(
        left: ${position.dx},
        top: ${position.dy},
        width: $width,
        height: $height,
        child: ${_buildWidgetType()},
      )
    ''';
  }

  /// 위젯 타입에 따른 Dart 코드를 생성하는 private 메서드
  String _buildWidgetType() {
    if (type == 'Button') {
      return '''
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0x${color.value.toRadixString(16).padLeft(8, '0')}),
          ),
          child: Text('$text'),
        )
      ''';
    } else {
      return '''
        Container(
          color: Color(0x${color.value.toRadixString(16).padLeft(8, '0')}),
          child: Center(child: Text('$text')),
        )
      ''';
    }
  }
}