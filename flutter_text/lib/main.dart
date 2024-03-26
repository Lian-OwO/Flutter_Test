import 'package:flutter/material.dart';
import 'package:flutter_text/openFile.dart';
import 'newPage.dart';
import 'openFile.dart';

void main() => runApp(MyApp());

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
      home: MyHomePage(),
    );
  }
}

//이동하는 페이지
class DetailScreen extends StatelessWidget {
  final String item;

  DetailScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Screen'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // 뒤로가기 버튼 눌렀을 때 MyHomePage로 돌아가기
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
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
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewPage(),
                        ),
                      );
                    },
                    child: Text('새로 만들기'),
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                    // 불러오기 버튼 눌렸을 때 실행할 동작
                    builder: (context) => OpenFile(),
                    ),
                    );
                  },
                  child: Text('불러오기'),
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
  @override
  Widget build(BuildContext context) {
    final items = List.generate(100, (i) => i).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('앱바 타이틀'),
        backgroundColor: Colors.cyan,
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              // "Home" 버튼을 누를 때 DetailScreen으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(item: '세부화면'),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Event'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.camera),
            title: Text('Camera'),
            trailing: Icon(Icons.navigate_next),
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
                          child: Text('첫번째 위젯'),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.blue,
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          child: Text('두번째 위젯'),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.green,
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          child: Text('세번째 위젯'),
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
                          child: Text('네번째 위젯'),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.teal,
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          child: Text('다섯번째 위젯'),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.deepPurpleAccent,
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          child: Text('여섯번째 위젯'),
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
                          child: Text('일곱번째 위젯'),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.purpleAccent,
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.all(8.0),
                          child: Text('여덟번째 위젯'),
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
