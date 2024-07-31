import 'package:flutter/material.dart';

class DroppedItem {
  Key key;
  String data;
  Offset position;
  Size size;
  Widget widget;
  List<DroppedItem> children;

  DroppedItem({
    required this.key,
    required this.data,
    required this.position,
    required this.size,
    required this.widget,
    List<DroppedItem>? children,
  }) : children = children ?? [];

  DroppedItem copyWith({
    Key? key,
    String? data,
    Offset? position,
    Size? size,
    Widget? widget,
    List<DroppedItem>? children,
  }) {
    return DroppedItem(
      key: key ?? this.key,
      data: data ?? this.data,
      position: position ?? this.position,
      size: size ?? this.size,
      widget: widget ?? this.widget,
      children: children ?? this.children,
    );
  }
}

class DragDropProvider extends ChangeNotifier {
  final List<DroppedItem> _droppedItems = [];
  DroppedItem? _selectedItem;

  List<DroppedItem> get droppedItems => _droppedItems;
  DroppedItem? get selectedItem => _selectedItem;

  void addItem(DroppedItem item) {
    _droppedItems.add(item);
    notifyListeners();
  }

  void updateItemPosition(String data, Offset newPosition) {
    final item = _findItem(data);
    if (item != null) {
      item.position = newPosition;
      notifyListeners();
    }
  }

  void updateItemSize(String data, Size newSize) {
    final item = _findItem(data);
    if (item != null) {
      item.size = newSize;
      if (item.data.startsWith('Container')) {
        item.widget = Container(
          width: newSize.width,
          height: newSize.height,
          decoration: (item.widget as Container).decoration,
        );
      } else if (item.data.startsWith('Button')) {
        final oldButton = (item.widget as SizedBox).child as ElevatedButton;
        item.widget = SizedBox(
          width: newSize.width,
          height: newSize.height,
          child: ElevatedButton(
            onPressed: () {}, // 빈 함수 할당
            child: oldButton.child,
            style: oldButton.style,
          ),
        );
      }
      notifyListeners();
    }
  }

  void removeItem(String data) {
    _removeItemRecursively(_droppedItems, data);
    notifyListeners();
  }

  void moveItemToContainer(DroppedItem item, String containerName, Offset newPosition) {
    removeItem(item.data);
    final container = _findItem(containerName);
    if (container != null) {
      final newItem = item.copyWith(position: newPosition);
      container.children.add(newItem);
      notifyListeners();
    }
  }

  void _removeItemRecursively(List<DroppedItem> items, String data) {
    for (int i = items.length - 1; i >= 0; i--) {
      if (items[i].data == data) {
        items.removeAt(i);
      } else {
        _removeItemRecursively(items[i].children, data);
      }
    }
  }

  DroppedItem? getItem(String data) {
    return _findItem(data);
  }

  List<DroppedItem> getContainerItems(String containerName) {
    final container = _findItem(containerName);
    return container?.children ?? [];
  }

  void addItemToContainer(DroppedItem item, String containerName, Offset localOffset) {
    final container = _findItem(containerName);
    if (container != null) {
      final adjustedOffset = Offset(
        localOffset.dx.clamp(0, container.size.width - item.size.width),
        localOffset.dy.clamp(0, container.size.height - item.size.height),
      );
      final newItem = item.copyWith(position: adjustedOffset);
      container.children.add(newItem);
      notifyListeners();
    }
  }

  void removeItemFromContainer(String containerName, String itemData) {
    final container = _findItem(containerName);
    if (container != null) {
      container.children.removeWhere((item) => item.data == itemData);
      notifyListeners();
    }
  }

  void updateItemPositionInContainer(String containerName, String itemData, Offset newPosition) {
    final container = _findItem(containerName);
    if (container != null) {
      final item = container.children.firstWhere((item) => item.data == itemData);
      item.position = newPosition;
      notifyListeners();
    }
  }

  void updateItemSizeInContainer(String containerName, String itemData, Size newSize) {
    final container = _findItem(containerName);
    if (container != null) {
      final item = container.children.firstWhere((item) => item.data == itemData);
      updateItemSize(item.data, newSize);
    }
  }

  void selectItem(String data) {
    _selectedItem = _findItem(data);
    notifyListeners();
  }

  void unselectItem() {
    _selectedItem = null;
    notifyListeners();
  }

  void updateItemProperties(String data, {String? newText, Color? newColor}) {
    final item = _findItem(data);
    if (item != null) {
      if (newText != null) {
        item.data = newText;
      }
      if (item.data.startsWith('Button')) {
        item.widget = SizedBox(
          width: item.size.width,
          height: item.size.height,
          child: ElevatedButton(
            onPressed: () {}, // 빈 함수 할당
            child: Text(newText ?? item.data),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(newColor ?? Colors.blue),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
          ),
        );
      } else if (item.data.startsWith('Container')) {
        item.widget = Container(
          width: item.size.width,
          height: item.size.height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: newColor ?? Colors.transparent,
          ),
        );
      }
      notifyListeners();
    }
  }

  DroppedItem? _findItem(String data) {
    return _findItemRecursively(_droppedItems, data);
  }

  DroppedItem? _findItemRecursively(List<DroppedItem> items, String data) {
    for (var item in items) {
      if (item.data == data) return item;
      final foundItem = _findItemRecursively(item.children, data);
      if (foundItem != null) return foundItem;
    }
    return null;
  }

  void updateContainerAndChildrenPositions(String containerData, Offset newPosition) {
    final container = _findItem(containerData);
    if (container != null) {
      container.position = newPosition;
      notifyListeners();
    }
  }

  DroppedItem? _draggingItem;
  String? _draggingItemParentContainer;

  void startDragging(DroppedItem item) {
    _draggingItem = item;
    _draggingItemParentContainer = _findParentContainer(item);
    if (_draggingItemParentContainer != null) {
      removeItemFromContainer(_draggingItemParentContainer!, item.data);
    } else {
      removeItem(item.data);
    }
    notifyListeners();
  }

  void endDragging(Offset offset) {
    if (_draggingItem != null) {
      addItem(_draggingItem!.copyWith(position: offset));
      _draggingItem = null;
      _draggingItemParentContainer = null;
      notifyListeners();
    }
  }

  String? _findParentContainer(DroppedItem item) {
    for (var containerItem in droppedItems) {
      if (containerItem.data.startsWith('Container')) {
        if (containerItem.children.any((child) => child.data == item.data)) {
          return containerItem.data;
        }
      }
    }
    return null;
  }

}