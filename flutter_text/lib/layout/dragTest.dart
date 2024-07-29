import 'package:flutter/material.dart';

// 앱 실행
void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ) // MaterialApp 감싸서 Context 분리
      );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Offset offset = const Offset(0, 0); //x,y 좌표를 가지고 있는 오프셋 객체 생성
  Offset offset2 = const Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("드래그 연습"), centerTitle: true),
      body: Stack(
        //스택 위젯을 이용해서 위젯을 겹칠 수 있도록 설정
        children: [
          Positioned(
            //스택의 자식 위치를 제어하는 위젯
            //오프셋 클래스 하나의 위치를 x,y로 지정
            left: offset.dx,
            top: offset.dy,
            child: GestureDetector(
              //제스처를 감지하는 위젯
              child: const Icon(
                Icons.car_rental,
              ),
              onPanUpdate: (details) {
                //드래그해서 이동한 위치만큼 Offset을 수정해서 State 변경
                setState(() {
                  offset = Offset(offset.dx + details.delta.dx,
                      offset.dy + details.delta.dy);
                });
              },
            ),
          ),
          Positioned(
            //스택의 자식 위치를 제어하는 위젯
            //오프셋 클래스 하나의 위치를 x,y로 지정
            left: offset2.dx,
            top: offset2.dy,
            child: GestureDetector(
              //제스처를 감지하는 위젯
              child: const Icon(
                Icons.star,
              ),
              onPanUpdate: (details) {
                //드래그해서 이동한 위치만큼 Offset을 수정해서 State 변경
                setState(() {
                  offset2 = Offset(offset2.dx + details.delta.dx,
                      offset2.dy + details.delta.dy);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
