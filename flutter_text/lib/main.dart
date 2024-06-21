import 'package:flutter/material.dart';
import 'package:flutter_text/openFile.dart';
import 'newPage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '데모앱',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: const MyHomePage(),
    );
  }
}

//이동하는 페이지
class DetailScreen extends StatelessWidget {
  final String item;

  const DetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Screen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 뒤로가기 버튼 눌렀을 때 MyHomePage로 돌아가기
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
                  (route) => false,
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewPage(),
                        ),
                      );
                    },
                    child: const Text('새로 만들기'),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                    // 불러오기 버튼 눌렸을 때 실행할 동작
                    builder: (context) => const OpenFile(),
                    ),
                    );
                  },
                  child: const Text('불러오기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}






class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(100, (i) => i).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('앱바 타이틀'),
        backgroundColor: Colors.cyan,
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              // "Home" 버튼을 누를 때 DetailScreen으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DetailScreen(item: '세부화면'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Event'),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Camera'),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {},
          ),
          Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          color: Colors.amber,
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          child: const Text('첫번째 위젯'),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.blue,
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          child: const Text('두번째 위젯'),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.green,
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          child: const Text('세번째 위젯'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          color: Colors.indigo,
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          child: const Text('네번째 위젯'),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.teal,
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          child: const Text('다섯번째 위젯'),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.deepPurpleAccent,
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          child: const Text('여섯번째 위젯'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          color: Colors.pink,
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          child: const Text('일곱번째 위젯'),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.purpleAccent,
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          child: const Text('여덟번째 위젯'),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.cyanAccent,
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            child: ListBody(
                              children: items.map((i) => Text('$i')).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
