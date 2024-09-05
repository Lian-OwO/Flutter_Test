import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/widget_provider.dart';
import '../models/widget_data.dart';

class PreviewArea extends StatelessWidget {
  const PreviewArea({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetProvider>(context);

    return DragTarget<String>(
      onAccept: (widgetType) {
        // 드랍된 위젯 타입에 따라 위젯 추가
        provider.addWidget(WidgetData(
          type: widgetType,
          position: const Offset(100, 100),  // 초기 위치
          width: 100,
          height: 100,
          color: widgetType == 'Button' ? Colors.blue : Colors.green,  // 타입에 따라 색상 변경
        ));
      },
      builder: (context, candidateData, rejectedData) {
        return Stack(
          children: provider.widgets.map((widgetData) {
            return Positioned(
              left: widgetData.position.dx,
              top: widgetData.position.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  // 드래그하여 위치 변경
                  final newPosition = widgetData.position + details.delta;
                  provider.updateWidgetPosition(widgetData.id, newPosition);
                },
                onTap: () {
                  // 위젯을 선택하면 편집 패널에 상태 반영
                  provider.selectWidget(widgetData.id);
                },
                child: _buildWidget(widgetData),  // 위젯 타입에 따른 위젯 생성
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // 위젯 타입에 따라 실제 위젯을 생성하는 함수
  Widget _buildWidget(WidgetData widgetData) {
    if (widgetData.type == 'Button') {
      return ElevatedButton(
        onPressed: () {},
        child: const Text('Button'),
      );
    } else if (widgetData.type == 'Container') {
      return Container(
        width: widgetData.width,
        height: widgetData.height,
        color: widgetData.color,
      );
    }
    return const SizedBox.shrink();
  }
}
