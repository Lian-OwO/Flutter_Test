import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(NewPage());
}

class NewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TextEditorPage(),
    );
  }
}

class TextEditorPage extends StatefulWidget {
  @override
  _TextEditorPageState createState() => _TextEditorPageState();
}

class _TextEditorPageState extends State<TextEditorPage> {
  final TextEditingController _textEditingController = TextEditingController();
  late String _filePath;

  @override
  void initState() {
    super.initState();
    _init(); // 파일 경로를 가져오고 파일을 읽는 함수를 호출
  }

  Future<void> _init() async {
    await _getFilePath(); // 파일 경로를 가져오는 함수 호출
    await _readFile(); // 파일을 읽는 함수 호출
  }

  Future<void> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    _filePath = '${directory.path}/my_text_file.txt';
  }

  Future<void> _readFile() async {
    try {
      final file = File(_filePath);
      if (await file.exists()) {
        final contents = await file.readAsString();
        setState(() {
          _textEditingController.text = contents;
        });
      }
    } catch (e) {
      print('Error reading file: $e');
    }
  }

  Future<void> _saveFile() async {
    final file = File(_filePath);
    await file.writeAsString(_textEditingController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Editor'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveFile();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textEditingController,
          maxLines: null,
        ),
      ),
    );
  }
}
