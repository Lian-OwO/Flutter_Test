import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../providers/widget_provider.dart';
import '../models/widget_data.dart';

/// PreviewArea 위젯: 사용자가 추가한 위젯들을 표시하고 상호작용할 수 있는 영역
class PreviewArea extends StatefulWidget {
  final bool isEditPanelOpen; // 편집 패널의 상태를 전달받는 새로운 속성

  const PreviewArea({Key? key, required this.isEditPanelOpen}) : super(key: key);

  @override
  _PreviewAreaState createState() => _PreviewAreaState();
}

class _PreviewAreaState extends State<PreviewArea> {
  Size? _previousSize;
  bool? _previousEditPanelState;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final currentSize = Size(constraints.maxWidth, constraints.maxHeight);

        bool editPanelStateChanged = _previousEditPanelState != null &&
            _previousEditPanelState != widget.isEditPanelOpen;

        if (_previousSize != null && _previousSize != currentSize && !editPanelStateChanged) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final provider = Provider.of<WidgetProvider>(context, listen: false);
            _adjustWidgetPositions(provider, _previousSize!, currentSize);
          });
        }

        _previousSize = currentSize;
        _previousEditPanelState = widget.isEditPanelOpen;

        return Consumer<WidgetProvider>(
          builder: (context, provider, child) {
            return DragTarget<String>(
              onWillAccept: (data) => true,
              onAcceptWithDetails: (details) {
                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final Offset localPosition = renderBox.globalToLocal(details.offset);

                final Offset dropPosition = Offset(
                  localPosition.dx.clamp(0, constraints.maxWidth),
                  localPosition.dy.clamp(0, constraints.maxHeight),
                );

                provider.addWidget(WidgetData(
                  type: details.data!,
                  position: dropPosition,
                  width: details.data == 'Button' ? 100 : 150,
                  height: details.data == 'Button' ? 50 : 100,
                  color: details.data == 'Button' ? Colors.blue : Colors.green,
                  text: details.data == 'Button' ? 'New Button' : 'New Container',
                ));
              },
              builder: (context, candidateData, rejectedData) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          provider.clearSelectedWidget();
                        },
                        child: Container(color: provider.backgroundColor),
                      ),
                    ),
                    ...provider.widgets.map((widgetData) {
                      return Positioned(
                        left: widgetData.position.dx,
                        top: widgetData.position.dy,
                        child: _buildDraggableWidget(context, widgetData, provider, constraints),
                      );
                    }).toList(),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// PreviewArea 크기 변경 시 위젯들의 위치를 조정하는 메서드
  void _adjustWidgetPositions(WidgetProvider provider, Size oldSize, Size newSize) {
    for (var widget in provider.widgets) {
      // 위젯의 현재 위치를 유지
      double newX = widget.position.dx;
      double newY = widget.position.dy;

      // PreviewArea를 벗어나지 않도록 조정
      newX = newX.clamp(0.0, newSize.width - widget.width);
      newY = newY.clamp(0.0, newSize.height - widget.height);

      // 위치가 변경된 경우에만 업데이트
      if (newX != widget.position.dx || newY != widget.position.dy) {
        provider.updateWidgetPositionWhileDragging(widget.id, Offset(newX, newY));
      }
    }
  }

  /// 드래그 가능한 위젯과 크기 조절 핸들을 포함한 위젯 빌드
  Widget _buildDraggableWidget(BuildContext context, WidgetData widgetData, WidgetProvider provider, BoxConstraints constraints) {
    return Stack(
      children: [
        Listener(
          onPointerDown: (event) => provider.startDragging(widgetData.id),
          onPointerMove: (event) {
            if (event.buttons == kPrimaryMouseButton) {
              final newPosition = widgetData.position + event.delta;
              final clampedPosition = Offset(
                newPosition.dx.clamp(0, constraints.maxWidth - widgetData.width),
                newPosition.dy.clamp(0, constraints.maxHeight - widgetData.height),
              );
              provider.updateWidgetPositionWhileDragging(widgetData.id, clampedPosition);
            }
          },
          onPointerUp: (event) => provider.endDragging(),
          child: GestureDetector(
            onTap: () => provider.selectWidget(widgetData.id),
            child: _buildWidget(context, widgetData, provider),
          ),
        ),
        // 선택된 위젯에만 크기 조절 핸들 표시
        if (provider.selectedWidget?.id == widgetData.id) ...[
          _buildResizeHandle(widgetData, provider, constraints, ResizeDirection.horizontal),
          _buildResizeHandle(widgetData, provider, constraints, ResizeDirection.vertical),
        ],
      ],
    );
  }

  /// 크기 조절 핸들 빌드
  Widget _buildResizeHandle(WidgetData widgetData, WidgetProvider provider, BoxConstraints constraints, ResizeDirection direction) {
    final isHorizontal = direction == ResizeDirection.horizontal;
    return Positioned(
      right: isHorizontal ? 0 : null,
      bottom: !isHorizontal ? 0 : null,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (isHorizontal) {
            final newWidth = (widgetData.width + details.delta.dx).clamp(10.0, constraints.maxWidth - widgetData.position.dx);
            provider.updateWidgetSize(widgetData.id, newWidth: newWidth);
          } else {
            final newHeight = (widgetData.height + details.delta.dy).clamp(10.0, constraints.maxHeight - widgetData.position.dy);
            provider.updateWidgetSize(widgetData.id, newHeight: newHeight);
          }
        },
        child: Container(
          width: isHorizontal ? 10 : widgetData.width,
          height: !isHorizontal ? 10 : widgetData.height,
          color: Colors.blue.withOpacity(0.5),
          child: Center(
            child: Icon(
              isHorizontal ? Icons.drag_handle : Icons.drag_handle,
              size: 10,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// 위젯 타입에 따라 적절한 위젯 빌드
  Widget _buildWidget(BuildContext context, WidgetData widgetData, WidgetProvider provider) {
    final isSelected = provider.selectedWidget?.id == widgetData.id;
    final borderSide = isSelected ? BorderSide(color: Colors.red, width: 2) : BorderSide.none;

    TextStyle textStyle = TextStyle(
      fontSize: widgetData.fontSize, //폰트 사이즈 반영
      color: widgetData.textColor, //폰트 컬러 반영
      fontFamily: widgetData.fontFamily, //폰트 변경 반영
      fontWeight: widgetData.isBold ? FontWeight.bold : FontWeight.normal,  // bold 적용
      fontStyle: widgetData.isItalic ? FontStyle.italic : FontStyle.normal,  // italic 적용
    );

    if (widgetData.type == 'Button') {
      return SizedBox(
        width: widgetData.width,
        height: widgetData.height,
        child: ElevatedButton(
          onPressed: () {
            provider.selectWidget(widgetData.id);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widgetData.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: borderSide,
            ),
          ),
          child: Text(
            widgetData.text ?? 'Button',
            style: textStyle,
          ),
        ),
      );
    } else if (widgetData.type == 'Container') {
      return Container(
        width: widgetData.width,
        height: widgetData.height,
        decoration: BoxDecoration(
          color: widgetData.color,
          border: Border.fromBorderSide(borderSide),
        ),
        child: Center(
          child: Text(
            widgetData.text ?? 'Container',
            style: textStyle,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }




}


/// 크기 조절 방향을 정의하는 열거형
enum ResizeDirection { horizontal, vertical }
