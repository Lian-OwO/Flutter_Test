import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'widget_provider.dart';
import '../models/widget_data.dart';
import 'package:uuid/uuid.dart';

/// CodeImportExportProvider 클래스: 코드 가져오기/내보내기 및 파싱을 담당
class CodeImportExportProvider with ChangeNotifier {
  final WidgetProvider widgetProvider;

  CodeImportExportProvider(this.widgetProvider);

  /// 전체 Dart 코드 생성
  String generateFullDartCode() {
    final buffer = StringBuffer();
    buffer.writeln("import 'package:flutter/material.dart';");
    buffer.writeln();
    buffer.writeln("class Generated extends StatelessWidget {");
    buffer.writeln("  @override");
    buffer.writeln("  Widget build(BuildContext context) {");
    buffer.writeln("    return Scaffold(");
    buffer.writeln("      body: Stack(");
    buffer.writeln("        children: [");

    for (var widget in widgetProvider.widgets) {
      buffer.writeln("          Positioned(");
      buffer.writeln("            left: ${widget.position.dx},");
      buffer.writeln("            top: ${widget.position.dy},");
      buffer.writeln("            child: ${_generateWidgetCode(widget)},");
      buffer.writeln("          ),");
    }

    buffer.writeln("        ],");
    buffer.writeln("      ),");
    buffer.writeln("    );");
    buffer.writeln("  }");
    buffer.writeln("}");

    return buffer.toString();
  }

  /// 개별 위젯의 코드 생성
  String _generateWidgetCode(WidgetData widget) {
    //텍스트 이스케이프
    String escapedText = widget.text.replaceAll("'", r"\'").replaceAll('\n', r'\n');

    final textStyle = '''
    style: TextStyle(
      fontSize: ${widget.fontSize},
      color: Color(0x${widget.textColor.value.toRadixString(16).padLeft(8, '0')}),
      fontWeight: ${widget.isBold ? 'FontWeight.bold' : 'FontWeight.normal'},
      fontStyle: ${widget.isItalic ? 'FontStyle.italic' : 'FontStyle.normal'},
      fontFamily: '${widget.fontFamily}',
    )
  ''';

    final commonProperties = '''
    width: ${widget.width},
    height: ${widget.height},
    backgroundColor: Color(0x${widget.backgroundColor.value.toRadixString(16).padLeft(8, '0')}),
  ''';

    if (widget.type == 'Button') {
      return '''ElevatedButton(
            onPressed: () {},
            child: Text(
              '$escapedText',
              $textStyle,
            ),
            style: ElevatedButton.styleFrom(
              $commonProperties
            ),
          ) // ID: ${widget.id}''';
    } else if (widget.type == 'Container') {
      return '''Container(
            $commonProperties
            child: Center(
              child: Text(
                '$escapedText',
                $textStyle,
              ),
            ),
          ) // ID: ${widget.id}''';
    }
    return 'SizedBox.shrink() // ID: ${widget.id}';
  }

  /// 코드를 파일로 내보내기
  Future<void> exportCode(BuildContext context) async {
    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save generated code',
        fileName: 'generated_code.dart',
      );

      if (outputFile != null) {
        final file = File(outputFile);
        final code = generateFullDartCode();
        await file.writeAsString(code);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code exported successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export code: $e')),
      );
    }
  }

  /// 파일에서 코드 가져오기
  Future<void> importCode(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['dart'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final widgets = parseCodeToWidgets(content);
        widgetProvider.setWidgets(widgets);
        //변경전달
        widgetProvider.notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code imported successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import code: $e')),
      );
    }
  }

  void updateWidgetsFromCode(String code) {
    final widgets = parseCodeToWidgets(code);
    print("Parsed ${widgets.length} widgets from code");
    for (var widget in widgets) {
      print("Parsed widget: ID=${widget.id}, Text='${widget.text}', BackgroundColor=${widget.backgroundColor}, TextColor=${widget.textColor}");
    }
    widgetProvider.updateWidgetsFromCode(widgets);
  }

  /// 코드를 파싱하여 WidgetData 객체 리스트로 변환
  List<WidgetData> parseCodeToWidgets(String code) {
    List<WidgetData> parsedWidgets = [];

    // Positioned 위젯의 정규 표현식
    RegExp widgetRegex = RegExp(
        r'Positioned\(\s*'
        r'left:\s*([\d.]+),\s*'
        r'top:\s*([\d.]+),\s*'
        r'child:\s*(Container|ElevatedButton)\('
        r'(?:[^)]+)\)'
        r'.*?//\s*ID:\s*([a-f0-9-]+)',
        multiLine: true,
        dotAll: true
    );

    var matches = widgetRegex.allMatches(code);

    for (var match in matches) {
      double left = double.parse(match.group(1)!);
      double top = double.parse(match.group(2)!);
      String type = match.group(3) == 'Container' ? 'Container' : 'Button';
      String id = match.group(4)!;

      String widgetContent = match.group(0)!;

      // 정규 표현식을 이용하여 위젯의 세부 정보를 파싱
      RegExp textRegex = RegExp("Text\\(\\s*['\"](.+?)['\"]", dotAll: true);
      RegExp sizeRegex = RegExp(r'(?:width|fixedSize):\s*(?:Size\()?([\d.]+)(?:,\s*([\d.]+))?\)?');
      RegExp fontSizeRegex = RegExp(r'fontSize:\s*([\d.]+)');
      RegExp fontWeightRegex = RegExp(r'fontWeight:\s*FontWeight\.(\w+)');
      RegExp fontStyleRegex = RegExp(r'fontStyle:\s*FontStyle\.(\w+)');
      RegExp fontFamilyRegex = RegExp("fontFamily:\\s*['\"](.+?)['\"]");
      // 색상 파싱 정규표현식
      RegExp backgroundColorRegex = RegExp(r'(?:backgroundColor|color):\s*Color\(0x([0-9A-Fa-f]+)\)');
      RegExp textColorRegex = RegExp(r'Text\(.*?style:\s*TextStyle\(.*?color:\s*Color\(0x([0-9A-Fa-f]+)\)', dotAll: true);
      RegExp buttonBackgroundColorRegex = RegExp(r'ElevatedButton\.styleFrom\(.*?backgroundColor:\s*Color\(0x([0-9A-Fa-f]+)\)', dotAll: true);


      // 값 추출 (null-safe 처리 추가)
      String text = textRegex.firstMatch(widgetContent)?.group(1) ?? '';
      double width = double.tryParse(sizeRegex.firstMatch(widgetContent)?.group(1) ?? '100') ?? 100;
      double height = double.tryParse(sizeRegex.firstMatch(widgetContent)?.group(2) ?? '50') ?? 50;
      double fontSize = double.tryParse(fontSizeRegex.firstMatch(widgetContent)?.group(1) ?? '14') ?? 14;
      bool isBold = fontWeightRegex.firstMatch(widgetContent)?.group(1) == 'bold';
      bool isItalic = fontStyleRegex.firstMatch(widgetContent)?.group(1) == 'italic';
      String fontFamily = fontFamilyRegex.firstMatch(widgetContent)?.group(1) ?? 'Roboto';

      String? bgColorValue = backgroundColorRegex.firstMatch(widgetContent)?.group(1);
      String? txtColorValue = textColorRegex.firstMatch(widgetContent)?.group(1);




      //색상 파싱 컬러
      Color backgroundColor;
      if (type == 'Button') {
        String? buttonBgColorValue = buttonBackgroundColorRegex.firstMatch(widgetContent)?.group(1);
        backgroundColor = buttonBgColorValue != null ? Color(int.parse(buttonBgColorValue, radix: 16)) : Colors.blue;
      } else {
        backgroundColor = bgColorValue != null ? Color(int.parse(bgColorValue, radix: 16)) : Colors.transparent;
      }
      Color textColor = txtColorValue != null ? Color(int.parse(txtColorValue, radix: 16)) : Colors.black;



      // 디버깅 로그
      print("Parsed widget - ID: $id, Type: $type, Position: ($left, $top), Text: $text, BackgroundColor: $backgroundColor, TextColor: $textColor");
      print("Background Color: $backgroundColor, Text Color: $textColor");
      print("Parsed colors - Background: $backgroundColor, Text: $textColor");
      print("Widget content: $widgetContent");
      print("Text regex match: ${textRegex.firstMatch(widgetContent)}");
      print("Raw text color value: $txtColorValue");
      print("Parsed widget - ID: $id, Type: $type");
      print("  Parsed background color: $backgroundColor");
      print("  Parsed text color: $textColor");


      // 위젯 데이터를 리스트에 추가
      parsedWidgets.add(WidgetData(
        id: id,
        type: type,
        position: Offset(left, top),
        width: width,
        height: height,
        backgroundColor: backgroundColor,  // 'color' 대신 'backgroundColor' 사용
        text: text,
        fontSize: fontSize,
        textColor: textColor,
        isBold: isBold,
        isItalic: isItalic,
        fontFamily: fontFamily,
      ));
    }

    if (parsedWidgets.isEmpty) {
      print("No widgets parsed from code.");
    }

    return parsedWidgets;
  }
}