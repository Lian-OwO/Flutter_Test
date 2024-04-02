import 'package:flutter/material.dart';
import 'component.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> _droppedButtons = []; // 작업 영역에 추가된 버튼들
  List<String> _canvasWidgets = ['Button']; // 캔버스에 존재하는 버튼 리스트
  int _buttonCount = 1; // 버튼 카운트

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Drag and Drop Example'),
        ),
        body: Row(
          children: [
            // 왼쪽 캔버스
            Expanded(
              flex: 1,
              child: Component(
                onDrop: (data) {
                  // 왼쪽 영역에 드롭될 때의 동작 처리
                  // 여기서는 아무 작업도 하지 않음
                }, canvasWidgets: [],
              ),
            ),
            // 가운데 캔버스 (작업 영역)
            Expanded(
              flex: 8,
              child: DragTarget<String>(
                onWillAccept: (data) {
                  // 드롭 가능 여부 확인
                  return true;
                },
                onAccept: (data) {
                  // 드롭된 경우, 작업 영역에 버튼 추가
                  setState(() {
                    final buttonName = 'Button$_buttonCount'; // 버튼 이름 생성
                    _droppedButtons.add(
                      Draggable<String>(
                        data: buttonName,
                        childWhenDragging: Container(), // 드래그 중에는 빈 컨테이너 표시
                        feedback: Material(
                          elevation: 4.0,
                          child: Container(
                            width: 100.0,
                            height: 50.0,
                            color: Colors.grey,
                            child: Center(child: Text(buttonName)),
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // 버튼을 클릭했을 때의 처리
                            print('$buttonName 클릭');
                          },
                          child: Text(buttonName),
                        ),
                      ),
                    );
                    _buttonCount++; // 버튼 카운트 증가
                  });
                },
                builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedData) {
                  return Container(
                    color: Colors.grey[300],
                    child: Column(
                      children: [
                        // 작업 영역 텍스트
                        if (_droppedButtons.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              '작업 영역',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // 작업 영역에 추가된 버튼들
                        ..._droppedButtons.map((button) => _buildDragTarget(button)).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragTarget(Widget button) {
    return DragTarget<String>(
      builder: (BuildContext context, List<String?> candidateData, List<dynamic> rejectedData) {
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: button,
        );
      },
      onWillAccept: (data) => true,
      onAccept: (data) {
        setState(() {
          _droppedButtons.remove(button); // 이전 위치의 버튼 삭제
          _droppedButtons.add(button); // 새로운 위치의 버튼 추가
        });
      },
    );
  }
}
