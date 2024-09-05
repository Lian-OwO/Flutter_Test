import 'package:flutter/material.dart';

class DroppedItem {
  Offset position;
  Size size;

  DroppedItem({
    required this.position,
    required this.size,
  });
}

class DragAndDropProvider extends ChangeNotifier {
  final List<DroppedItem> _droppedItems = [];

  List<DroppedItem> get droppedItems => _droppedItems;

  void addItem() {
    _droppedItems.add(DroppedItem(
      position: const Offset(50, 50),
      size: const Size(100, 100),
    ));
    notifyListeners();
  }

  void updateItemPosition(DroppedItem item, Offset delta) {
    final index = _droppedItems.indexOf(item);
    _droppedItems[index] = DroppedItem(
      position: item.position + delta,
      size: item.size,
    );
    notifyListeners();
  }
}
