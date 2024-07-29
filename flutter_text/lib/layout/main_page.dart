import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'drag_drop_provider.dart';
import 'component.dart';
import 'dart:math' as math;

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DragDropProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('드래그 앤 드롭 테스트'),
      ),
      body: Row(
        children: [
          // 컴포넌트 영역
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(8.0),
              child: Component(onDrop: (data) {}),
            ),
          ),
          // 작업 영역
          Expanded(
            flex: 8,
            child: Container(
              color: Colors.grey[100],
              child: _buildWorkArea(provider),
            ),
          ),
          // 속성 편집 패널
          if (provider.selectedItem != null)
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey[300],
                child: _buildPropertyPanel(provider.selectedItem!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkArea(DragDropProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DragTarget<Object>(
          builder: (context, candidateData, rejectedData) {
            return Stack(
              children: provider.droppedItems.map((item) => _buildPositionedItem(item, null, constraints)).toList(),
            );
          },
          onAcceptWithDetails: (details) {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final localPosition = renderBox.globalToLocal(details.offset);

            if (details.data is String) {
              final newItem = _createItem(details.data as String, localPosition);
              if (newItem != null) {
                provider.addItem(newItem);
              }
            } else if (details.data is DroppedItem) {
              final droppedItem = details.data as DroppedItem;
              provider.updateItemPosition(droppedItem.data, localPosition);
            }
          },
        );
      },
    );
  }

  Widget _buildPositionedItem(DroppedItem item, String? parentContainerName, BoxConstraints constraints) {
    final position = parentContainerName != null ? item.position : item.position;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: _buildDraggableItem(item, parentContainerName, constraints),
    );
  }

  Widget _buildDraggableItem(DroppedItem item, String? parentContainerName, BoxConstraints constraints) {
    final provider = Provider.of<DragDropProvider>(context, listen: false);

    Widget child;
    if (item.data.startsWith('Container')) {
      child = _buildDroppableContainer(item, constraints);
    } else if (item.data.startsWith('Button')) {
      final button = item.widget as SizedBox;
      final elevatedButton = button.child as ElevatedButton;
      child = SizedBox(
        width: item.size.width,
        height: item.size.height,
        child: ElevatedButton(
          onPressed: () {
            elevatedButton.onPressed?.call();
            provider.selectItem(item.data);
            setState(() {});
          },
          child: elevatedButton.child,
          style: elevatedButton.style,
        ),
      );
    } else {
      child = item.widget;
    }

    return Draggable<DroppedItem>(
      data: item,
      feedback: Material(
        child: Opacity(
          opacity: 0.7,
          child: child,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: child,
      ),
      onDragStarted: () {
        if (parentContainerName != null) {
          provider.removeItemFromContainer(parentContainerName, item.data);
        }
      },
      onDragEnd: (details) {
        if (!details.wasAccepted) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final localPosition = renderBox.globalToLocal(details.offset);

          final adjustedPosition = Offset(
            localPosition.dx.clamp(0, constraints.maxWidth - item.size.width),
            localPosition.dy.clamp(0, constraints.maxHeight - item.size.height),
          );

          if (parentContainerName != null) {
            // 컨테이너 내부 아이템의 경우 상대적 위치를 계산
            final container = provider.getItem(parentContainerName);
            if (container != null) {
              final relativePosition = adjustedPosition - container.position;
              provider.updateItemPositionInContainer(parentContainerName, item.data, relativePosition);
            }
          } else {
            if (item.data.startsWith('Container')) {
              provider.updateContainerAndChildrenPositions(item.data, adjustedPosition);
            } else {
              provider.updateItemPosition(item.data, adjustedPosition);
            }
          }
        }
      },
      child: ResizableWidget(
        initialSize: item.size,
        child: child,
        onRemove: () {
          if (parentContainerName != null) {
            provider.removeItemFromContainer(parentContainerName, item.data);
          } else {
            provider.removeItem(item.data);
          }
          provider.unselectItem();
          setState(() {});
        },
        onUpdatePosition: (newPosition) {
          final adjustedPosition = Offset(
            (item.position.dx + newPosition.dx).clamp(0, constraints.maxWidth - item.size.width),
            (item.position.dy + newPosition.dy).clamp(0, constraints.maxHeight - item.size.height),
          );
          if (parentContainerName != null) {
            provider.updateItemPositionInContainer(parentContainerName, item.data, adjustedPosition);
          } else {
            provider.updateItemPosition(item.data, adjustedPosition);
          }
        },
        onResize: (newSize) {
          if (parentContainerName != null) {
            provider.updateItemSizeInContainer(parentContainerName, item.data, newSize);
          } else {
            provider.updateItemSize(item.data, newSize);
          }
        },
      ),
    );
  }

  Widget _buildDroppableContainer(DroppedItem containerItem, BoxConstraints parentConstraints) {
    final provider = Provider.of<DragDropProvider>(context, listen: false);

    return DragTarget<DroppedItem>(
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: () {
            provider.selectItem(containerItem.data);
            setState(() {});
          },
          child: Container(
            width: containerItem.size.width,
            height: containerItem.size.height,
            decoration: (containerItem.widget as Container).decoration,
            child: Stack(
              children: containerItem.children.map((child) {
                return Positioned(
                  left: child.position.dx,
                  top: child.position.dy,
                  child: _buildDraggableItem(
                    child,
                    containerItem.data,
                    BoxConstraints(
                      maxWidth: containerItem.size.width,
                      maxHeight: containerItem.size.height,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
      onAcceptWithDetails: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final localOffset = renderBox.globalToLocal(details.offset) - containerItem.position;

        final draggedItemWidth = (details.data as DroppedItem).size.width;
        final draggedItemHeight = (details.data as DroppedItem).size.height;

        final adjustedOffset = Offset(
          localOffset.dx.clamp(0, math.max(0, containerItem.size.width - draggedItemWidth)),
          localOffset.dy.clamp(0, math.max(0, containerItem.size.height - draggedItemHeight)),
        );

        if (details.data != containerItem) {
          provider.moveItemToContainer(details.data, containerItem.data, adjustedOffset);
        }
      },
    );
  }

  DroppedItem? _createItem(String data, Offset localOffset) {
    if (data.startsWith('Button')) {
      final buttonName = data;
      return DroppedItem(
        key: UniqueKey(),
        data: buttonName,
        position: localOffset,
        size: const Size(100, 50),
        widget: SizedBox(
          width: 100,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              print('Button pressed: $buttonName');
            },
            child: Text(buttonName),
          ),
        ),
      );
    } else if (data.startsWith('Container')) {
      final containerName = data;
      return DroppedItem(
        key: UniqueKey(),
        data: containerName,
        position: localOffset,
        size: const Size(200, 200),
        widget: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: Colors.transparent,
          ),
        ),
        children: [],
      );
    }
    return null;
  }

  Widget _buildPropertyPanel(DroppedItem item) {
    final provider = Provider.of<DragDropProvider>(context, listen: false);
    final TextEditingController textController = TextEditingController(text: item.data);
    final TextEditingController widthController = TextEditingController(text: item.size.width.toString());
    final TextEditingController heightController = TextEditingController(text: item.size.height.toString());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('속성 편집: ${item.data}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: textController,
              decoration: const InputDecoration(labelText: '텍스트'),
              onSubmitted: (value) {
                provider.updateItemProperties(item.data, newText: value);
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widthController,
                    decoration: const InputDecoration(labelText: '너비'),
                    keyboardType: TextInputType.number,
                    onSubmitted: (value) {
                      final newWidth = double.tryParse(value);
                      if (newWidth != null) {
                        provider.updateItemSize(item.data, Size(newWidth, item.size.height));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: heightController,
                    decoration: const InputDecoration(labelText: '높이'),
                    keyboardType: TextInputType.number,
                    onSubmitted: (value) {
                      final newHeight = double.tryParse(value);
                      if (newHeight != null) {
                        provider.updateItemSize(item.data, Size(item.size.width, newHeight));
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showColorPicker(context, (color) {
                  provider.updateItemProperties(item.data, newColor: color);
                });
              },
              child: const Text('색상 변경'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                provider.removeItem(item.data);
                provider.unselectItem();
              },
              child: const Text('삭제'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                provider.unselectItem();
              },
              child: const Text('선택 해제'),
            ),
          ],
        ),
      ),
    );
  }

  void showColorPicker(BuildContext context, Function(Color) onColorSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('색상 선택'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: Colors.blue,
              onColorChanged: onColorSelected,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class ResizableWidget extends StatefulWidget {
  final Widget child;
  final Size initialSize;
  final VoidCallback onRemove;
  final Function(Offset) onUpdatePosition;
  final Function(Size) onResize;

  const ResizableWidget({
    Key? key,
    required this.child,
    required this.initialSize,
    required this.onRemove,
    required this.onUpdatePosition,
    required this.onResize,
  }) : super(key: key);

  @override
  _ResizableWidgetState createState() => _ResizableWidgetState();
}

class _ResizableWidgetState extends State<ResizableWidget> {
  late Size size;

  @override
  void initState() {
    super.initState();
    size = widget.initialSize;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: widget.onRemove,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onPanUpdate: (details) {
              final newWidth = (size.width + details.delta.dx).clamp(10.0, double.infinity);
              final newHeight = (size.height + details.delta.dy).clamp(10.0, double.infinity);
              final newSize = Size(newWidth, newHeight);
              setState(() {
                size = newSize;
              });
              widget.onResize(newSize);
              widget.onUpdatePosition(Offset(0, 0));
            },
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.expand, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}