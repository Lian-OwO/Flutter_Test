import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/widget_provider.dart';
import '../utils/color_map.dart' as color_utils;
import '../models/widget_data.dart';
import 'package:flutter/rendering.dart';


/// 위젯 속성을 편집하기 위한 패널 위젯
class PropertyPanel extends StatelessWidget {

  const PropertyPanel({Key? key}) : super(key: key);

  List<String> getSystemFonts() {
    // 실제 시스템 폰트를 가져오는 대신, 일반적인 폰트 목록을 반환
    return [
      'Roboto',
      'Arial',
      'Helvetica',
      'Times New Roman',
      'Courier',
      'Verdana',
      'Georgia',
      'Palatino',
      'Garamond',
      'Bookman',
      'Comic Sans MS',
      'Trebuchet MS',
      'Arial Black',
      'Impact'
    ];
  }


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
          child: SingleChildScrollView(
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
                _buildFontProperties(selectedWidget, provider),
                const SizedBox(height: 10),
                _buildDeleteButton(selectedWidget, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 위젯 편집 헤더를 생성
  Widget _buildHeader(WidgetData widget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('Edit ${widget.type}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// 위젯의 크기 필드를 생성
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

  /// ValueListenable을 사용하는 TextField를 생성
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

  /// 위젯의 텍스트 필드를 생성
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

  /// 위젯 삭제 버튼을 생성
  Widget _buildDeleteButton(WidgetData widget, WidgetProvider provider) {
    return ElevatedButton(
      onPressed: () => provider.removeWidget(widget.id),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text('Delete Widget'),
    );
  }

  /// 위젯 색상 선택기를 생성
  Widget _buildColorSelector(WidgetData widget, WidgetProvider provider, {bool isTextColor = false}) {
    final colorMap = color_utils.getColorMap();
    return ValueListenableBuilder<Color>(
      valueListenable: isTextColor
          ? provider.getTextColorListenable(widget.id)
          : provider.getColorListenable(widget.id),
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
              if (isTextColor) {
                provider.updateWidgetTextColor(widget.id, newColor);
              } else {
                provider.updateWidgetBackgroundColor(widget.id, newColor);
              }
            }
          },
        );
      },
    );
  }

  /// 폰트 관련 속성을 편집하는 위젯을 생성
  Widget _buildFontProperties(WidgetData widget, WidgetProvider provider) {
    List<String> systemFonts = getSystemFonts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Font Properties', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildValueListenableTextField(
          valueListenable: provider.getFontSizeListenable(widget.id),
          label: 'Font Size',
          onSubmitted: (value) {
            final newSize = double.tryParse(value);
            if (newSize != null && newSize > 0) {
              provider.updateWidgetFontSize(widget.id, newSize);
            }
          },
        ),
        Text('Text Color'),
        _buildColorSelector(widget, provider, isTextColor: true),
        Row(
          children: [
            Checkbox(
              value: widget.isBold,
              onChanged: (value) {
                if (value != null) {
                  provider.updateWidgetBold(widget.id, value);
                }
              },
            ),
            Text('Bold'),
            const SizedBox(width: 20),
            Checkbox(
              value: widget.isItalic,
              onChanged: (value) {
                if (value != null) {
                  provider.updateWidgetItalic(widget.id, value);
                }
              },
            ),
            Text('Italic'),
          ],
        ),
        DropdownButton<String>(
          value: widget.fontFamily,
          items: systemFonts.map((String font) {
            return DropdownMenuItem<String>(
              value: font,
              child: Text(font),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              provider.updateWidgetFontFamily(widget.id, newValue);
            }
          },
        ),
      ],
    );
  }

  // /// 폰트 색상 선택기를 생성
  // Widget _buildFontColorSelector(WidgetData widget, WidgetProvider provider) {
  //   final colorMap = color_utils.getColorMap();
  //   return ValueListenableBuilder<Color>(
  //     valueListenable: provider.getTextColorListenable(widget.id),
  //     builder: (context, color, child) {
  //       String selectedColorName = 'Custom';
  //       for (var entry in colorMap.entries) {
  //         if (entry.value == color) {
  //           selectedColorName = entry.key;
  //           break;
  //         }
  //       }
  //
  //       return DropdownButton<String>(
  //         value: selectedColorName,
  //         items: [
  //           ...colorMap.keys.map((String name) {
  //             return DropdownMenuItem<String>(
  //               value: name,
  //               child: Row(
  //                 children: [
  //                   Container(
  //                     width: 20,
  //                     height: 20,
  //                     color: colorMap[name],
  //                     margin: EdgeInsets.only(right: 8),
  //                   ),
  //                   Text(name),
  //                 ],
  //               ),
  //             );
  //           }),
  //           if (selectedColorName == 'Custom')
  //             DropdownMenuItem<String>(
  //               value: 'Custom',
  //               child: Row(
  //                 children: [
  //                   Container(
  //                     width: 20,
  //                     height: 20,
  //                     color: color,
  //                     margin: EdgeInsets.only(right: 8),
  //                   ),
  //                   Text('Custom'),
  //                 ],
  //               ),
  //             ),
  //         ],
  //         onChanged: (String? newValue) {
  //           if (newValue != null) {
  //             Color newColor = colorMap[newValue] ?? color;
  //             provider.updateWidgetTextColor(widget.id, newColor);
  //           }
  //         },
  //       );
  //     },
  //   );
  // }

  /// 페이지 속성을 편집하는 위젯을 생성
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