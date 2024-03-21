import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;

import 'package:path_provider/path_provider.dart';
import 'newPage.dart';
import 'main.dart'; // DetailScreen 클래스를 import 합니다.

void main() {
  runApp(NewPage());
}

class NewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  late String _fileName;
  bool _isModified = false; // 파일이 수정되었는지 여부

  @override
  void initState() {
    super.initState();
    _fileName = ''; // 파일 이름 초기화
  }

  Future<void> _openFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        String filePath = result.files.single.path!;
        File file = File(filePath);
        String contents = await file.readAsString();
        setState(() {
          _textEditingController.text = contents;
          _fileName = result.files.single.name;
          _isModified = false; // 파일이 수정되지 않은 상태로 초기화
        });
      }
    } on PlatformException catch (e) {
      print('Error opening file: $e');
    }
  }

  // 파일을 로컬에 저장하거나 웹에서 다운로드하는 메서드
  Future<void> _saveFile() async {
    try {
      if (_isModified) { // 파일이 수정되었을 때만 저장 동작 수행
        String? directoryPath = await FilePicker.platform.getDirectoryPath();
        if (directoryPath != null) {
          _fileName = (await _getFileName())!;
          if (_fileName != null) {
            final String textToSave = _textEditingController.text;
            final File file = File('$directoryPath/$_fileName.txt'); // 확장자를 포함한 파일 경로 설정
            await file.writeAsString(textToSave);
            print('File saved successfully');

            // 웹 플랫폼에서는 다운로드 링크 생성
            if (kIsWeb) {
              final Uint8List bytes = file.readAsBytesSync();
              final blob = html.Blob([bytes]);
              final url = html.Url.createObjectUrlFromBlob(blob);
              html.AnchorElement(href: url)
                ..setAttribute('download', '$_fileName.txt')
                ..click();
              html.Url.revokeObjectUrl(url);
            }
          }
        }
      }
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  // 파일 이름을 입력 받는 대화상자 표시
  Future<String?> _getFileName() async {
    TextEditingController fileNameController = TextEditingController();
    String? fileName;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter File Name'),
          content: TextField(
            controller: fileNameController,
            decoration: InputDecoration(hintText: 'Enter file name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                fileName = fileNameController.text;
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새로 만들기'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          tooltip: '뒤로가기', // 버튼 위에 마우스를 가져가면 나타날 텍스트
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailScreen(item: '세부화면')),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveFile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _textEditingController,
          maxLines: null,
          onChanged: (value) {
            setState(() {
              _isModified = true; // 파일이 수정됨
            });
          },
        ),
      ),
    );
  }
}
