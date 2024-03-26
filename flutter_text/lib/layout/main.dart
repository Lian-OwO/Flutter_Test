import 'package:flutter/material.dart';
import 'component.dart';

void main() {
  runApp(MainPage());
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> _droppedButtons = []; // 작업 영역에 추가된 버튼들

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
              flex: 2,
              child: Component(
                onDrop: (data) {
                  // 작업 영역에 버튼 추가되었을 때 호출되는 콜백
                  // 여기서 버튼을 작업 영역에 추가함
                  setState(() {
                    _droppedButtons.add(ElevatedButton(
                      onPressed: () {
                        // 버튼을 클릭했을 때의 처리
                        print('추가된 버튼 클릭');
                      },
                      child: Text(data), // 드롭된 데이터를 버튼에 표시
                    ));
                  });
                },
              ),
            ),
            // 가운데 캔버스 (작업 영역)
            Expanded(
              flex: 6,
              child: Container(
                color: Colors.grey[300],
                child: Column(
                  children: [
                    // 작업 영역 텍스트
                    if (_droppedButtons.isEmpty)
                      Padding(
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
                    ..._droppedButtons,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
