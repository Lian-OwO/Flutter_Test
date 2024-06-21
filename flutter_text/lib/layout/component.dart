import 'package:flutter/material.dart';

class Component extends StatefulWidget {
  final Function(String) onDrop;

  const Component({Key? key, required this.onDrop}) : super(key: key);

  @override
  ComponentState createState() => ComponentState();
}

class ComponentState extends State<Component> {
  int buttonCount = 1;
  int containerCount = 1;
  String currentDraggingItem = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Draggable<String>(
          data: 'Button$buttonCount',
          feedback: Material(
            elevation: 3.0,
            child: Builder(
              builder: (context) {
                return Container(
                  width: 100.0,
                  height: 50.0,
                  color: Colors.grey,
                  child: Center(child: Text(currentDraggingItem)),
                );
              },
            ),
          ),
          child: ElevatedButton(
            onPressed: () {
              print('버튼 클릭');
            },
            child: const Text('버튼'),
          ),
          onDragStarted: () {
            setState(() {
              currentDraggingItem = 'Button$buttonCount';
            });
            print('버튼 드래그 시작');
          },
          onDraggableCanceled: (_, __) {
            print('버튼 드래그 취소');
            setState(() {
              currentDraggingItem = '';
            });
          },
          onDragEnd: (details) {
            print('버튼 드래그 종료');
            setState(() {
              currentDraggingItem = '';
            });
            // 외부로 드롭되지 않은 경우에만 추가
            if (!details.wasAccepted) {
              widget.onDrop('Button$buttonCount');
            }
            setState(() {
              buttonCount++;
            });
          },
        ),
        const SizedBox(height: 20),
        Draggable<String>(
          data: 'Container$containerCount',
          feedback: Material(
            elevation: 3.0,
            child: Builder(
              builder: (context) {
                return Container(
                  width: 100.0,
                  height: 100.0,
                  color: Colors.blue,
                  child: Center(child: Text(currentDraggingItem)),
                );
              },
            ),
          ),
          child: ElevatedButton(
            onPressed: () {
              print('컨테이너 클릭');
            },
            child: const Text('컨테이너'),
          ),
          onDragStarted: () {
            setState(() {
              currentDraggingItem = 'Container$containerCount';
            });
            print('컨테이너 드래그 시작');
          },
          onDraggableCanceled: (_, __) {
            print('컨테이너 드래그 취소');
            setState(() {
              currentDraggingItem = '';
            });
          },
          onDragEnd: (details) {
            print('컨테이너 드래그 종료');
            setState(() {
              currentDraggingItem = '';
            });
            // 외부로 드롭되지 않은 경우에만 추가
            if (!details.wasAccepted) {
              widget.onDrop('Container$containerCount');
            }
            setState(() {
              containerCount++;
            });
          },
        ),
      ],
    );
  }
}
