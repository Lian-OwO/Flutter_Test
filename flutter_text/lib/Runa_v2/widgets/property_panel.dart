import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/widget_provider.dart';
import '../utils/color_map.dart';

class PropertyPanel extends StatefulWidget {
  const PropertyPanel({super.key});

  @override
  _PropertyPanelState createState() => _PropertyPanelState();
}

class _PropertyPanelState extends State<PropertyPanel> {
  late TextEditingController widthController;
  late TextEditingController heightController;

  @override
  void initState() {
    super.initState();
    widthController = TextEditingController();
    heightController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateControllers();  // 패널이 열릴 때마다 컨트롤러 값 업데이트
  }

  // 선택된 위젯의 가로, 세로 값을 텍스트 필드에 반영
  void _updateControllers() {
    final provider = Provider.of<WidgetProvider>(context, listen: false);
    final widget = provider.selectedWidget;

    if (widget != null) {
      widthController.text = widget.width.toStringAsFixed(2);
      heightController.text = widget.height.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    widthController.dispose();
    heightController.dispose();
    super.dispose();
  }

  // 가로값 업데이트 및 동기화 처리
  void _updateWidth(String value) {
    final newWidth = double.tryParse(value);
    if (newWidth != null) {
      final provider = Provider.of<WidgetProvider>(context, listen: false);
      final widget = provider.selectedWidget;
      if (widget != null) {
        // 가로만 업데이트
        provider.updateWidgetSize(widget.id, newWidth: newWidth);
        setState(() {
          widthController.text = newWidth.toStringAsFixed(2);  // 컨트롤러 값 반영
        });
      }
    }
  }

  // 세로값 업데이트 및 동기화 처리
  void _updateHeight(String value) {
    final newHeight = double.tryParse(value);
    if (newHeight != null) {
      final provider = Provider.of<WidgetProvider>(context, listen: false);
      final widget = provider.selectedWidget;
      if (widget != null) {
        // 세로만 업데이트
        provider.updateWidgetSize(widget.id, newHeight: newHeight);
        setState(() {
          heightController.text = newHeight.toStringAsFixed(2);  // 컨트롤러 값 반영
        });
      }
    }
  }

  // 색상 업데이트 및 동기화 처리
  void _updateColor(Color? newColor) {
    if (newColor != null) {
      final provider = Provider.of<WidgetProvider>(context, listen: false);
      final widget = provider.selectedWidget;
      if (widget != null) {
        provider.updateWidgetColor(widget.id, newColor);
        setState(() {});  // 색상 변경 후 즉시 패널 업데이트
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WidgetProvider>(
      builder: (context, provider, child) {
        final widget = provider.selectedWidget;

        if (!provider.isPanelVisible || widget == null) {
          return Container(); // 패널이 보이지 않거나 선택된 위젯이 없을 때 빈 컨테이너
        }

        return Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.grey[300],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit ${widget.type}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      provider.togglePanelVisibility();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'ID: ${widget.id}',  // UUID를 표시
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: widthController,
                decoration: const InputDecoration(labelText: 'Width'),
                onSubmitted: _updateWidth,  // 값을 수정하고 엔터를 누르면 호출
              ),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: 'Height'),
                onSubmitted: _updateHeight,  // 값을 수정하고 엔터를 누르면 호출
              ),
              const SizedBox(height: 10),
              // 색상 드롭다운
              DropdownButton<Color>(
                value: widget.color,
                onChanged: _updateColor,  // 색상 선택 시 호출
                items: _getColorItems(),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  provider.removeWidget(widget.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Delete Widget'),
              ),
            ],
          ),
        );
      },
    );
  }

  List<DropdownMenuItem<Color>> _getColorItems() {
    final colorMap = getColorMap();
    return colorMap.entries.map((entry) {
      return DropdownMenuItem<Color>(
        value: entry.value,
        child: Row(
          children: [
            Container(
              width: 20,
              height: 10,
              color: entry.value,
            ),
            const SizedBox(width: 10),
            Text(entry.key),
          ],
        ),
      );
    }).toList();
  }
}
