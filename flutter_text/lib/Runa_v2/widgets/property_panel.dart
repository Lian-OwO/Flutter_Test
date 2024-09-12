import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; //ValueListenable 사용을 위한 호출
import 'package:provider/provider.dart'; //프로바이더 사용
import '../providers/widget_provider.dart';
import '../utils/color_map.dart';
import '../models/widget_data.dart';

/// PropertyPanel 위젯: 선택된 위젯의 속성을 편집하는 패널
class PropertyPanel extends StatelessWidget {
  const PropertyPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // WidgetProvider를 통해 위젯 상태 관리
    return Consumer<WidgetProvider>(
      builder: (context, provider, child) {
        final selectedWidget = provider.selectedWidget;

        // 패널이 보이지 않거나 선택된 위젯이 없으면 빈 컨테이너 반환
        if (!provider.isPanelVisible || selectedWidget == null) {
          return Container();
        }

        // 속성 편집 패널 UI 구성
        return Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.grey[300],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(selectedWidget, provider),
              const SizedBox(height: 10),
              Text('ID: ${selectedWidget.id}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 10),
              _buildDimensionFields(selectedWidget, provider),
              _buildWidgetTextField(selectedWidget, provider),
              const SizedBox(height: 10),
              _buildColorSelector(selectedWidget, provider),
              const SizedBox(height: 10),
              _buildDeleteButton(selectedWidget, provider),
            ],
          ),
        );
      },
    );
  }

  /// 패널 헤더 구성
  Widget _buildHeader(WidgetData widget, WidgetProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Edit ${widget.type}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: provider.togglePanelVisibility,
          tooltip: 'Close panel',
        ),
      ],
    );
  }

  /// 위젯 크기 조절 필드 구성
  Widget _buildDimensionFields(WidgetData widget, WidgetProvider provider) {
    return Column(
      children: [
        _buildValueListenableTextField(
          valueListenable: provider.getWidthListenable(widget.id),
          label: 'Width',
          onSubmitted: (value) {
            final newWidth = double.tryParse(value);
            if (newWidth != null && newWidth > 10) {  // 최소값 체크
              provider.updateWidgetSize(widget.id, newWidth: newWidth);
            }
          },
        ),
        _buildValueListenableTextField(
          valueListenable: provider.getHeightListenable(widget.id),
          label: 'Height',
          onSubmitted: (value) {
            final newHeight = double.tryParse(value);
            if (newHeight != null && newHeight > 10) {  // 최소값 체크
              provider.updateWidgetSize(widget.id, newHeight: newHeight);
            }
          },
        ),
      ],
    );
  }

  /// ValueListenable을 사용한 텍스트 필드 생성
  Widget _buildValueListenableTextField({
    required ValueListenable<double> valueListenable,
    required String label,
    required Function(String) onSubmitted,
  }) {
    return ValueListenableBuilder<double>(
      valueListenable: valueListenable,
      builder: (context, value, child) {
        return TextField(
          decoration: InputDecoration(labelText: label),
          controller: TextEditingController(text: value.toString()),
          onSubmitted: onSubmitted,  // onChanged 대신 onSubmitted 사용
          keyboardType: TextInputType.number,  // 숫자 키보드 사용
        );
      },
    );
  }

  /// 위젯 텍스트 편집 필드 구성
  Widget _buildWidgetTextField(WidgetData widget, WidgetProvider provider) {
    return ValueListenableBuilder<String>(
      valueListenable: provider.getTextListenable(widget.id),
      builder: (context, value, child) {
        return TextField(
          decoration: const InputDecoration(labelText: 'Text'),
          controller: TextEditingController(text: value),
          onSubmitted: (newValue) {  // onChanged 대신 onSubmitted 사용
            provider.updateWidgetText(widget.id, newValue);
          },
        );
      },
    );
  }

  /// 색상 선택기 구성
  Widget _buildColorSelector(WidgetData widget, WidgetProvider provider) {
    return ValueListenableBuilder<Color>(
      valueListenable: provider.getColorListenable(widget.id),
      builder: (context, color, child) {
        return DropdownButton<Color>(
          value: color,
          onChanged: (newColor) {
            if (newColor != null) {
              provider.updateWidgetColor(widget.id, newColor);
            }
          },
          items: getColorMap().entries.map((entry) {
            return DropdownMenuItem<Color>(
              value: entry.value,
              child: Row(
                children: [
                  Container(width: 20, height: 20, color: entry.value),
                  const SizedBox(width: 10),
                  Text(entry.key),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// 삭제 버튼 구성
  Widget _buildDeleteButton(WidgetData widget, WidgetProvider provider) {
    return ElevatedButton(
      onPressed: () => provider.removeWidget(widget.id),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text('Delete Widget'),
    );
  }
}