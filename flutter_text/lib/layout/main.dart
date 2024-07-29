import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'drag_drop_provider.dart';
import 'main_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DragDropProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '드래그 앤 드롭 테스트',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        splashFactory: NoSplash.splashFactory, // 음영 효과 비활성화
      ),
      home: const MainPage(),
    );
  }
}