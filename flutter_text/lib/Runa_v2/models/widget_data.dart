import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// WidgetData 클래스: 위젯의 속성 및 데이터를 관리
class WidgetData {
  final String id;
  final String type;
  Offset position;
  Offset? _originalPosition;
  double width;
  double height;
  Color color;
  String text;
  double? fontSize;
  Color textColor;
  bool isBold;
  bool isItalic;
  String fontFamily;

  /// 생성자: 필수 속성을 받아 위젯 데이터를 초기화
  WidgetData({
    String? id,
    required this.type,
    required this.position,
    Offset? originalPosition,
    required this.width,
    required this.height,
    required this.color,
    this.text = '',
    this.fontSize,
    this.textColor = Colors.black,
    this.isBold = false,
    this.isItalic = false,
    this.fontFamily = 'Roboto',

  }) : id = id ?? const Uuid().v4() {  // UUID는 처음에만 생성
    // originalPosition이 null이면 현재 position을 사용
    _originalPosition = originalPosition ?? position;
    fontSize ??= 14.0;  // null이면 기본값 설정
  }

  /// originalPosition getter: originalPosition이 null이면 position 반환
  Offset get originalPosition => _originalPosition ?? position;

  /// 위젯의 복사본을 생성하는 메서드: 주어진 속성만 변경 가능
  WidgetData copyWith({
    String? id,
    String? type,
    Offset? position,
    Offset? originalPosition,
    double? width,
    double? height,
    Color? color,
    String? text,
    double? fontSize,
    Color? textColor,
    bool? isBold,
    bool? isItalic,
    String? fontFamily,
  }) {
    return WidgetData(
      id: id ?? this.id,  // UUID는 변경되지 않도록 유지
      type: type ?? this.type,
      position: position ?? this.position,
      originalPosition: originalPosition ?? _originalPosition,
      width: width ?? this.width,
      height: height ?? this.height,
      color: color ?? this.color,
      text: text ?? this.text,  // 텍스트가 전달되지 않으면 기존 텍스트 유지
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      isBold: isBold ?? this.isBold,  // Bold 상태 유지
      isItalic: isItalic ?? this.isItalic,  // Italic 상태 유지
      fontFamily: fontFamily ?? this.fontFamily,
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

  /// 위젯 데이터를 JSON 형식으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'position': {'dx': position.dx, 'dy': position.dy},
      'originalPosition': {'dx': originalPosition.dx, 'dy': originalPosition.dy},
      'width': width,
      'height': height,
      'color': color.value,
      'text': text,
      'fontSize': fontSize,
      'textColor': textColor.value,
      'isBold': isBold,
      'isItalic': isItalic,
    };
  }

  /// JSON 데이터를 WidgetData 객체로 변환하는 팩토리 메서드
  factory WidgetData.fromJson(Map<String, dynamic> json) {
    return WidgetData(
      id: json['id'],  // JSON에서 기존 UUID 사용
      type: json['type'],
      position: Offset(json['position']['dx'], json['position']['dy']),
      width: json['width'],
      height: json['height'],
      color: Color(json['color']),
      text: json['text'],
      fontSize: json['fontSize'],
      textColor: Color(json['textColor']),
      isBold: json['isBold'],
      isItalic: json['isItalic'],
    );
  }
}
