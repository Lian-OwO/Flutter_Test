import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'main.dart';

void main() {
  runApp(const OpenFile());
}

class OpenFile extends StatelessWidget {
  const OpenFile({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TextEditorPage(),
    );
  }
}

class TextEditorPage extends StatefulWidget {
  const TextEditorPage({super.key});

  @override
  _TextEditorPageState createState() => _TextEditorPageState();
}

class _TextEditorPageState extends State<TextEditorPage> {
  final TextEditingController _textEditingController = TextEditingController();
  late String _filePath;
  late String _fileName;
  bool _isModified = false; // 파일이 수정되었는지 여부

  @override
  void initState() {
    super.initState();
    _fileName = ''; // 파일 이름 초기화
    _init();
  }

  Future<void> _init() async {
    await _getFilePath();
  }

  Future<void> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    _filePath = '${directory.path}/$_fileName.txt'; // 확장자를 포함한 파일 경로 설정
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
          _filePath = filePath; // 선택된 파일의 경로로 업데이트
          _isModified = false; // 파일이 수정되지 않은 상태로 초기화
        });
      }
    } on PlatformException catch (e) {
      print('Error opening file: $e');
    }
  }

  Future<void> _saveFile() async {
    try {
      if (_isModified) { // 파일이 수정되었을 때만 저장 동작 수행
        if (_fileName.isNotEmpty) { // 파일 이름이 빈 문자열이 아닌 경우
          final String textToSave = _textEditingController.text;
          final File file = File(_filePath);
          await file.writeAsString(textToSave);
          print('File saved successfully');
          _isModified = false; // 저장 후 수정 상태 초기화
        } else {
          _fileName = (await _getFileName()) ?? ''; // 파일 이름 입력 받기
          if (_fileName.isNotEmpty) { // 파일 이름이 빈 문자열이 아닌 경우에만 저장 수행
            final String textToSave = _textEditingController.text;
            final String? directoryPath = await FilePicker.platform
                .getDirectoryPath();
            if (directoryPath != null) {
              // 디렉토리 경로가 null이 아닌 경우에만 계속 진행합니다.
              final String finalDirectoryPath = directoryPath;
              // 이후에 finalDirectoryPath를 사용합니다.
            } else {
              // 디렉토리 경로가 null인 경우에 대한 처리를 추가할 수 있습니다.
              // 예를 들어 사용자에게 경고를 표시하거나 기본 경로를 사용할 수 있습니다.
            }

            final File file = File(
                '$directoryPath/$_fileName.txt'); // 확장자를 포함한 파일 경로 설정
            await file.writeAsString(textToSave);
            print('File saved successfully');
            _isModified = false; // 저장 후 수정 상태 초기화
          }
        }
      }
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  //다른이름저장
  // 파일 저장하는 메서드
  Future<void> _saveAsFile() async {
    try {
      if (_isModified) { // 파일이 수정되었을 때만 저장 동작 수행
        String? directoryPath = await FilePicker.platform.getDirectoryPath();
        if (directoryPath != null) {
          _fileName = (await _getFileName())!;
          final String textToSave = _textEditingController.text;
          final File file = File('$directoryPath/$_fileName.txt'); // 확장자를 포함한 파일 경로 설정
          await file.writeAsString(textToSave);
          print('File saved successfully');
          _fileName = ''; // 파일 이름 초기화
                }
      }
    } catch (e) {
      print('Error saving file: $e');
    }
  }


  //파일삭제
  // 파일을 삭제하고 데스크탑 스토리지에서도 삭제하는 메서드
  Future<void> _deleteFile() async {
    try {
      final File file = File(_filePath);
      await file.delete(); // 파일 삭제
      print('File deleted successfully');
      _fileName = ''; // 파일 이름 초기화

      // 텍스트 에디터의 내용을 비워줍니다.
      _textEditingController.clear();

      // 데스크톱 스토리지에서도 삭제합니다.
      if (!kIsWeb) {
        // 웹 플랫폼이 아닌 경우에만 데스크톱 스토리지에서 삭제합니다.
        final directoryPath = await getApplicationDocumentsDirectory();
        final desktopFile = File('${directoryPath.path}/$_fileName.txt');
        await desktopFile.delete();
        print('File deleted from desktop storage');
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }



  Future<String?> _getFileName() async {
    TextEditingController fileNameController = TextEditingController();
    String? fileName;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('파일 이름 입력'),
          content: TextField(
            controller: fileNameController,
            decoration: const InputDecoration(hintText: '파일이름 입력'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                fileName = fileNameController.text;
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    return fileName;
  }


  //앱바설정
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('파일 풀러오기'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          tooltip: '뒤로가기', // 버튼 위에 마우스를 가져가면 나타날 텍스트
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DetailScreen(item: '세부화면')),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFile,
            tooltip: '저장', // 버튼 위에 마우스를 가져가면 나타날 텍스트
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _saveAsFile,
            tooltip: '다른 이름으로 저장', // 버튼 위에 마우스를 가져가면 나타날 텍스트
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _openFile,
            tooltip: '열기', // 버튼 위에 마우스를 가져가면 나타날 텍스트
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteFile,
            tooltip: '파일삭제', // 버튼 위에 마우스를 가져가면 나타날 텍스트
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
              _isModified = true;
            });
          },
        ),
      ),
    );
  }


}
