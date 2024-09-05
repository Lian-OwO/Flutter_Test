import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';  // 고유 ID생성하는 uuid 패키지

class WidgetData {
  final String id;  // 고유 uuid
  final String type;
  Offset position;
  double width;
  double height;
  Color color;

  WidgetData({
    String? id,  // uuid는 제공받거나 생성
    required this.type,
    required this.position,
    required this.width,
    required this.height,
    required this.color,
  }) : id = id ?? const Uuid().v4();  //UUID 생성

  WidgetData copyWith({
    String? id,
    String? type,
    Offset? position,
    double? width,
    double? height,
    Color? color,
  }) {
    return WidgetData(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      width: width ?? this.width,
      height: height ?? this.height,
      color: color ?? this.color,
    );
  }

  // 위젯을 Dart 코드로 변환 (예: 미리보기 또는 코드 출력용)
  String toDartCode() {
    return '''
      Positioned(
        left: ${position.dx},
        top: ${position.dy},
        width: $width,
        height: $height,
        child: ${_buildWidgetType()},
        id: $id,
      )
    ''';
  }
  String _buildWidgetType() {
    if (type == 'Button') {
      return '''
        ElevatedButton(
          onPressed: () {},
          child: const Text('Button'),
        )
      ''';
    } else {
      return '''
        Container(
          color: ${color.toString()},
          child: const Center(child: Text('$type')),
        )
      ''';
    }
  }
}

