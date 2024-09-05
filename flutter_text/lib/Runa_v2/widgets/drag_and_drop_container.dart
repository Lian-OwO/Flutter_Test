import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drag_drop_provider.dart';

class DragDropContainer extends StatefulWidget {
  const DragDropContainer({super.key});

  @override
  _DragDropContainerState createState() => _DragDropContainerState();
}

class _DragDropContainerState extends State<DragDropContainer> {
  @override
  Widget build(BuildContext context) {
    final dragProvider = Provider.of<DragAndDropProvider>(context);

    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        return Stack(
          children: dragProvider.droppedItems.map((item) {
            return Positioned(
              left: item.position.dx,
              top: item.position.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    // 드래그로 위치 이동
                    item.position += details.delta;
                    dragProvider.notifyListeners();
                  });
                },
                onScaleUpdate: (details) {
                  setState(() {
                    // 두 손가락으로 크기 조정
                    final newSize = item.size * details.scale;
                    if (newSize.width > 50 && newSize.height > 50) {
                      item.size = newSize;
                      dragProvider.notifyListeners();
                    }
                  });
                },
                child: Container(
                  width: item.size.width,
                  height: item.size.height,
                  color: Colors.blue[100],
                  child: const Center(child: Text("Dropped Widget")),
                ),
              ),
            );
          }).toList(),
        );
      },
      onAccept: (widgetType) {
        dragProvider.addItem(); // 드롭된 위치에 아이템 추가
      },
    );
  }
}
