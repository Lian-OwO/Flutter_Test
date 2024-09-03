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
      children: children ?? List.from(this.children),
    );
  }
}

class DragDropProvider extends ChangeNotifier {
  final List<DroppedItem> _droppedItems = [];
  DroppedItem? _selectedItem;
  DroppedItem? _draggingItem;
  String? _draggingItemParentContainer;

  List<DroppedItem> get droppedItems => _droppedItems;
  DroppedItem? get selectedItem => _selectedItem;
  DroppedItem? get draggingItem => _draggingItem;

  void addItem(DroppedItem item) {
    _droppedItems.add(item);
    notifyListeners();
  }

  void updateItemPosition(String data, Offset newPosition, String? containerName) {
    if (containerName != null) {
      final container = _findItemRecursively(_droppedItems, containerName);
      if (container != null) {
        final item = container.children.firstWhere((item) => item.data == data, orElse: () => DroppedItem(key: UniqueKey(), data: '', position: Offset.zero, size: Size.zero, widget: Container()));
        if (item.data.isNotEmpty) {
          item.position = newPosition;
        }
      }
    } else {
      final item = _findItemRecursively(_droppedItems, data);
      if (item != null) {
        item.position = newPosition;
      }
    }
    notifyListeners();
  }

  void updateItemSize(String data, Size newSize) {
    final item = _findItemRecursively(_droppedItems, data);
    if (item != null) {
      item.size = newSize;
      _updateWidgetSize(item, newSize);
      notifyListeners();
    }
  }

  void _updateWidgetSize(DroppedItem item, Size newSize) {
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
          onPressed: oldButton.onPressed,
          child: oldButton.child,
          style: oldButton.style,
        ),
      );
    }
  }

  void removeItem(String data) {
    bool removed = _removeItemRecursively(_droppedItems, data);
    if (removed && _selectedItem?.data == data) {
      _selectedItem = null;
    }
    notifyListeners();
  }

  bool _removeItemRecursively(List<DroppedItem> items, String data) {
    for (int i = items.length - 1; i >= 0; i--) {
      if (items[i].data == data) {
        items.removeAt(i);
        return true;
      } else if (_removeItemRecursively(items[i].children, data)) {
        return true;
      }
    }
    return false;
  }

  DroppedItem? getItem(String data) {
    return _findItemRecursively(_droppedItems, data);
  }

  List<DroppedItem> getContainerItems(String containerName) {
    final container = _findItemRecursively(_droppedItems, containerName);
    return container?.children ?? [];
  }

  void addItemToContainer(DroppedItem item, String containerName, Offset localOffset) {
    final container = _findItemRecursively(_droppedItems, containerName);
    if (container != null) {
      final newItem = item.copyWith(position: localOffset);
      container.children.add(newItem);
      notifyListeners();
    }
  }

  void removeItemFromContainer(String containerName, String itemData) {
    final container = _findItemRecursively(_droppedItems, containerName);
    if (container != null) {
      container.children.removeWhere((item) => item.data == itemData);
      notifyListeners();
    }
  }

  void updateItemPositionInContainer(String containerName, String itemData, Offset newPosition) {
    final container = _findItemRecursively(_droppedItems, containerName);
    if (container != null) {
      final item = container.children.firstWhere((item) => item.data == itemData);
      item.position = newPosition;
      notifyListeners();
    }
  }

  void updateItemSizeInContainer(String containerName, String itemData, Size newSize) {
    final container = _findItemRecursively(_droppedItems, containerName);
    if (container != null) {
      final item = container.children.firstWhere((item) => item.data == itemData);
      item.size = newSize;
      _updateWidgetSize(item, newSize);
      notifyListeners();
    }
  }

  void selectItem(String data) {
    _selectedItem = _findItemRecursively(_droppedItems, data);
    notifyListeners();
  }

  void unselectItem() {
    _selectedItem = null;
    notifyListeners();
  }

  void updateItemProperties(String data, {String? newText, Color? newColor}) {
    final item = _findItemRecursively(_droppedItems, data);
    if (item != null) {
      if (newText != null) {
        item.data = newText;
      }
      _updateWidgetProperties(item, newColor);
      notifyListeners();
    }
  }

  void _updateWidgetProperties(DroppedItem item, Color? newColor) {
    if (item.data.startsWith('Button')) {
      item.widget = SizedBox(
        width: item.size.width,
        height: item.size.height,
        child: ElevatedButton(
          onPressed: () {}, // 빈 함수 할당
          child: Text(item.data),
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
  }

  DroppedItem? _findItemRecursively(List<DroppedItem> items, String data) {
    for (var item in items) {
      if (item.data == data) return item;
      final foundItem = _findItemRecursively(item.children, data);
      if (foundItem != null) return foundItem;
    }
    return null;
  }

  void startDragging(DroppedItem item) {
    _draggingItem = item;
    _draggingItemParentContainer = _findParentContainer(item);
    print('드래깅 시작: ${item.data}, 부모 컨테이너: $_draggingItemParentContainer');
    notifyListeners();
  }

  void endDragging(Offset offset, {String? newContainerName}) {
    if (_draggingItem != null) {
      print('드래깅 종료: ${_draggingItem!.data}, 새 위치: $offset, 새 컨테이너: $newContainerName');
      moveItem(_draggingItem!.data, offset, _draggingItemParentContainer);
      _draggingItem = null;
      _draggingItemParentContainer = null;
      notifyListeners();
    }
  }

  void cancelDragging() {
    print('드래깅 취소: ${_draggingItem?.data}');
    _draggingItem = null;
    _draggingItemParentContainer = null;
    notifyListeners();
  }

  String? _findParentContainer(DroppedItem item) {
    for (var containerItem in _droppedItems) {
      if (containerItem.data.startsWith('Container')) {
        if (_findItemRecursively(containerItem.children, item.data) != null) {
          return containerItem.data;
        }
      }
    }
    return null;
  }

  void moveItem(String itemData, Offset newPosition, String? oldContainerName) {
    DroppedItem? item;
    if (oldContainerName != null) {
      // 컨테이너 내부에서 이동하는 경우
      final container = _findItemRecursively(_droppedItems, oldContainerName);
      if (container != null) {
        final index = container.children.indexWhere((child) => child.data == itemData);
        if (index != -1) {
          item = container.children.removeAt(index);
        }
      }
    } else {
      // 작업 영역에서 이동하는 경우
      final index = _droppedItems.indexWhere((element) => element.data == itemData);
      if (index != -1) {
        item = _droppedItems.removeAt(index);
      }
    }

    if (item != null) {
      final updatedItem = item.copyWith(position: newPosition);
      _droppedItems.add(updatedItem);
    }

    notifyListeners();
  }

  void moveItemToContainer(String itemData, String containerName, Offset newPosition) {
    DroppedItem? item = _removeItemFromCurrentLocation(itemData);
    if (item != null) {
      final container = _findItemRecursively(_droppedItems, containerName);
      if (container != null) {
        final newItem = item.copyWith(position: newPosition);
        container.children.add(newItem);
        notifyListeners();
      } else {
        // 컨테이너를 찾지 못한 경우, 아이템을 원래 위치로 되돌립니다.
        _droppedItems.add(item);
      }
    }
  }

  DroppedItem? _removeItemFromCurrentLocation(String itemData) {
    // 최상위 레벨에서 아이템 찾기
    int index = _droppedItems.indexWhere((item) => item.data == itemData);
    if (index != -1) {
      return _droppedItems.removeAt(index);
    }

    // 모든 컨테이너 내부에서 아이템 찾기
    for (var container in _droppedItems.where((item) => item.data.startsWith('Container'))) {
      index = container.children.indexWhere((item) => item.data == itemData);
      if (index != -1) {
        return container.children.removeAt(index);
      }
    }

    return null;
  }
}