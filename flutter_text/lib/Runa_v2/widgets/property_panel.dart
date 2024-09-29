import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/widget_provider.dart';
import '../utils/color_map.dart' as color_utils;
import '../models/widget_data.dart';

class PropertyPanel extends StatelessWidget {
  const PropertyPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WidgetProvider>(
      builder: (context, provider, child) {
        final selectedWidget = provider.selectedWidget;

        if (selectedWidget == null) {
          return _buildPageProperties(context, provider);
        }

        return Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.grey[300],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(selectedWidget),
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

  Widget _buildHeader(WidgetData widget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('Edit ${widget.type}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDimensionFields(WidgetData widget, WidgetProvider provider) {
    return Column(
      children: [
        _buildValueListenableTextField(
          valueListenable: provider.getWidthListenable(widget.id),
          label: 'Width',
          onSubmitted: (value) {
            final newWidth = double.tryParse(value);
            if (newWidth != null && newWidth > 10) {
              provider.updateWidgetSize(widget.id, newWidth: newWidth);
            }
          },
        ),
        _buildValueListenableTextField(
          valueListenable: provider.getHeightListenable(widget.id),
          label: 'Height',
          onSubmitted: (value) {
            final newHeight = double.tryParse(value);
            if (newHeight != null && newHeight > 10) {
              provider.updateWidgetSize(widget.id, newHeight: newHeight);
            }
          },
        ),
      ],
    );
  }

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
          onSubmitted: onSubmitted,
          keyboardType: TextInputType.number,
        );
      },
    );
  }

  Widget _buildWidgetTextField(WidgetData widget, WidgetProvider provider) {
    return ValueListenableBuilder<String>(
      valueListenable: provider.getTextListenable(widget.id),
      builder: (context, value, child) {
        return TextField(
          decoration: const InputDecoration(labelText: 'Text'),
          controller: TextEditingController(text: value),
          onSubmitted: (newValue) {
            provider.updateWidgetText(widget.id, newValue);
          },
        );
      },
    );
  }

  Widget _buildDeleteButton(WidgetData widget, WidgetProvider provider) {
    return ElevatedButton(
      onPressed: () => provider.removeWidget(widget.id),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text('Delete Widget'),
    );
  }

  Widget _buildColorSelector(WidgetData widget, WidgetProvider provider) {
    final colorMap = color_utils.getColorMap();
    return ValueListenableBuilder<Color>(
      valueListenable: provider.getColorListenable(widget.id),
      builder: (context, color, child) {
        String selectedColorName = 'Custom';
        for (var entry in colorMap.entries) {
          if (entry.value == color) {
            selectedColorName = entry.key;
            break;
          }
        }

        return DropdownButton<String>(
          value: selectedColorName,
          items: [
            ...colorMap.keys.map((String name) {
              return DropdownMenuItem<String>(
                value: name,
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      color: colorMap[name],
                      margin: EdgeInsets.only(right: 8),
                    ),
                    Text(name),
                  ],
                ),
              );
            }),
            if (selectedColorName == 'Custom')
              DropdownMenuItem<String>(
                value: 'Custom',
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      color: color,
                      margin: EdgeInsets.only(right: 8),
                    ),
                    Text('Custom'),
                  ],
                ),
              ),
          ],
          onChanged: (String? newValue) {
            if (newValue != null) {
              Color newColor = colorMap[newValue] ?? color;
              provider.updateWidgetColor(widget.id, newColor);
            }
          },
        );
      },
    );
  }

  Widget _buildPageProperties(BuildContext context, WidgetProvider provider) {
    final colorMap = color_utils.getColorMap();
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Page Properties', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: Text('Safe Area'),
            value: provider.safeArea,
            onChanged: (bool value) {
              provider.toggleSafeArea(value);
            },
          ),
          ListTile(
            title: Text('Background Color'),
            trailing: DropdownButton<Color>(
              value: provider.backgroundColor,
              onChanged: (newColor) {
                if (newColor != null) {
                  provider.changeBackgroundColor(newColor);
                }
              },
              items: colorMap.entries.map((entry) {
                return DropdownMenuItem<Color>(
                  value: entry.value,
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        color: entry.value,
                      ),
                      const SizedBox(width: 10),
                      Text(entry.key),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: Text('Show Navigation Bar'),
            value: provider.showNavBar,
            onChanged: (bool value) {
              provider.toggleNavBar(value);
            },
          ),
        ],
      ),
    );
  }
}