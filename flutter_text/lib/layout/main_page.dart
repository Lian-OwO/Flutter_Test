import 'package:flutter/material.dart';
import 'component.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  List<Widget> droppedItems = [];
  List<Offset> itemOffsets = [];
  int buttonCount = 1;
  int containerCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drag and Drop Test'),
      ),
      body: Row(
        children: [
          // 왼쪽 컴포넌트 영역
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Component는 사용자 정의 위젯으로, onDrop 콜백을 제공합니다.
                Component(
                  onDrop: (data) {
                    setState(() {
                      // Component 영역에서는 여기에서 처리하지 않음
                    });
                  },
                ),
              ],
            ),
          ),
          // 오른쪽 드롭 영역
          Expanded(
            flex: 8,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: constraints.maxHeight,
                  color: Colors.grey[300],
                  child: DragTarget<String>(
                    onWillAcceptWithDetails: (details) => true,
                    onAcceptWithDetails: (details) {
                      final RenderBox renderBox = context.findRenderObject() as RenderBox;
                      final localOffset = renderBox.globalToLocal(details.offset);

                      if (!isItemInWorkspace(details.data)) {
                        if (details.data.startsWith('Button')) {
                          setState(() {
                            droppedItems.add(buildDraggableButton());
                            itemOffsets.add(localOffset);
                          });
                        } else if (details.data.startsWith('Container')) {
                          setState(() {
                            droppedItems.add(buildDraggableContainer());
                            itemOffsets.add(localOffset);
                          });
                        }
                      } else {
                        final index = droppedItems.indexWhere((element) => element.key.toString() == details.data);
                        if (index != -1) {
                          setState(() {
                            itemOffsets[index] = localOffset;
                          });
                        }
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Stack(
                        children: [
                          if (droppedItems.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  '작업 영역',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ...droppedItems.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final offset = itemOffsets[index];
                            return Positioned(
                              left: offset.dx,
                              top: offset.dy,
                              child: Draggable<String>(
                                data: item.key.toString(),
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Opacity(
                                    opacity: 0.5,
                                    child: Container(
                                      width: item is ElevatedButton ? 100.0 : 100.0,
                                      height: item is ElevatedButton ? 50.0 : 100.0,
                                      color: item is ElevatedButton ? Colors.grey : Colors.blue,
                                      child: Center(
                                        child: Text(
                                          item.key.toString(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Container(
                                  width: item is ElevatedButton ? 100.0 : 100.0,
                                  height: item is ElevatedButton ? 50.0 : 100.0,
                                  color: item is ElevatedButton ? Colors.grey : Colors.blue,
                                ),
                                onDragEnd: (details) {
                                  setState(() {
                                    final RenderBox renderBox = context.findRenderObject() as RenderBox;
                                    final localOffset = renderBox.globalToLocal(details.offset);
                                    itemOffsets[index] = localOffset;
                                  });
                                },
                                child: GestureDetector(
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("아이템 삭제"),
                                          content: const Text("삭제 하시겠습니까?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("취소"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                _removeItem(index);
                                              },
                                              child: const Text("삭제"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: item,
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDraggableButton() {
    String buttonName = 'Button$buttonCount';
    buttonCount++;
    return ElevatedButton(
      onPressed: () {
        print('$buttonName 클릭');
      },
      key: ValueKey(buttonName),
      child: Text(buttonName),
    );
  }

  Widget buildDraggableContainer() {
    String containerName = 'Container$containerCount';
    containerCount++;
    return Container(
      width: 100.0,
      height: 100.0,
      color: Colors.blue,
      key: ValueKey(containerName),
      child: Center(
        child: Text(containerName),
      ),
    );
  }

  bool isItemInWorkspace(String? data) {
    return droppedItems.any((widget) => widget.key.toString() == data);
  }

  void _removeItem(int index) {
    setState(() {
      droppedItems.removeAt(index);
      itemOffsets.removeAt(index);
    });
  }
}
