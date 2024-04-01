import 'package:flutter/material.dart';

class Component extends StatefulWidget {
  final Function(String) onDrop; // 드롭될 때 호출되는 콜백 함수
  final List<String> canvasWidgets; // 캔버스에 존재하는 위젯 리스트

  Component({required this.onDrop, required this.canvasWidgets});

  @override
  _ComponentState createState() => _ComponentState();
}

class _ComponentState extends State<Component> {
  int _buttonCount = 1; // 버튼 이름에 추가될 숫자, 초기값은 1로 설정

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: 'Button', // 드래그할 때 전달할 데이터
      feedback: Material(
        elevation: 4.0,
        child: Container(
          width: 100.0,
          height: 50.0,
          color: Colors.grey,
          child: Center(child: Text('Button')), // 드래그 중에 표시될 버튼
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          // 버튼을 클릭했을 때의 처리
          print('버튼 클릭');
        },
        child: Text('Button'),
      ),
      // 다운 이벤트 처리
      onDragStarted: () {
        // 다운 이벤트 처리
        print('드래그 시작');
      },
      onDraggableCanceled: (_, __) {
        // 드래그가 취소됨을 처리
        print('드래그 취소');
      },
      onDragEnd: (details) {
        // 드래그 종료 시, 작업 영역에 버튼 추가
        print('드래그 종료');
        if (!details.wasAccepted) {
          // 작업 영역에 버튼 추가할 수 있도록 처리
          String buttonName = 'Button$_buttonCount';
          // 캔버스에 버튼 이름이 이미 존재하는지 확인하고 중복을 방지하기 위해 숫자를 증가시킴
          while (widgetExists(buttonName)) {
            _buttonCount++;
            buttonName = 'Button$_buttonCount';
          }
          widget.onDrop(buttonName);
        }
      },
    );
  }

  bool widgetExists(String name) {
    // 캔버스에 버튼이 존재하는지 확인하는 함수
    return widget.canvasWidgets.contains(name);
  }
}
