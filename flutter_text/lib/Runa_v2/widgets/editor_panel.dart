import 'package:flutter/material.dart';

class EditorPanel extends StatelessWidget {
  const EditorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Widgets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildDraggableWidget(context, 'Container'),
          _buildDraggableWidget(context, 'Button'),
        ],
      ),
    );
  }

  Widget _buildDraggableWidget(BuildContext context, String widgetType) {
    return Draggable<String>(
      data: widgetType,  // 드래그할 데이터로 위젯 타입 전달
      feedback: Material(
        child: Opacity(
          opacity: 0.7,
          child: Container(
            padding: const EdgeInsets.all(10),
            color: Colors.blueAccent,
            child: Text(widgetType, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.blueAccent,
        child: Text(widgetType, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
