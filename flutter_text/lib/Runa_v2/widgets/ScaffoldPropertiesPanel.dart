import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/page_provider.dart';  // 페이지 상태를 관리할 프로바이더

class ScaffoldPropertiesPanel extends StatelessWidget {
  const ScaffoldPropertiesPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageProvider = Provider.of<PageProvider>(context);

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Page Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: Text('Safe Area'),
            value: pageProvider.safeArea,
            onChanged: (bool value) { pageProvider.setSafeArea(value); },
          ),
          SwitchListTile(
            title: Text('Show Navbar'),
            value: pageProvider.showNavBar,
            onChanged: (bool value) { pageProvider.setShowNavBar(value); },
          ),
          ColorPicker(
            label: 'Background Color',
            currentColor: pageProvider.backgroundColor,
            onColorChanged: (Color newColor) { pageProvider.setBackgroundColor(newColor); },
          ),
        ],
      ),
    );
  }
}

class ColorPicker extends StatelessWidget {
  final String label;
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({Key? key, required this.label, required this.currentColor, required this.onColorChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: currentColor,
          shape: BoxShape.circle,
        ),
        child: InkWell(
          onTap: () {
            // Open color picker dialog
          },
        ),
      ),
    );
  }
}
