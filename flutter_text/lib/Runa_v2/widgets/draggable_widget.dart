import 'package:flutter/material.dart';

class DraggableWidget extends StatelessWidget {
  final String widgetType;

  const DraggableWidget({super.key, required this.widgetType});

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: widgetType, // 드래그되는 데이터 전달
      feedback: Material(
        child: Opacity(
          opacity: 0.7,
          child: _buildWidgetFromType(widgetType),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.blueAccent,
        child: Text(widgetType, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // 위젯 타입에 따라 생성할 위젯 결정
  Widget _buildWidgetFromType(String widgetType) {
    if (widgetType == "Text") {
      return const Text(
        "Hello, World!",
        style: TextStyle(fontSize: 20, color: Colors.black),
      );
    } else if (widgetType == "Button") {
      return ElevatedButton(
        onPressed: () {},
        child: const Text("Click Me"),
      );
    }
    return Container(); // 기본값으로 빈 컨테이너 반환
  }
}
