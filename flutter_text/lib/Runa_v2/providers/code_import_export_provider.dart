import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'widget_provider.dart';
import '../models/widget_data.dart';
import 'package:uuid/uuid.dart';

class CodeImportExportProvider with ChangeNotifier {
  final WidgetProvider widgetProvider;

  CodeImportExportProvider(this.widgetProvider);

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

  String _generateWidgetCode(WidgetData widget) {
    if (widget.type == 'Button') {
      return '''ElevatedButton(
              onPressed: () {},
              child: Text('${widget.text}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0x${widget.color.value.toRadixString(16)
          .padLeft(8, '0')}),
                fixedSize: Size(${widget.width}, ${widget.height}),
              ),
            ) // ID: ${widget.id}''';
    } else if (widget.type == 'Container') {
      return '''Container(
              width: ${widget.width},
              height: ${widget.height},
              color: Color(0x${widget.color.value.toRadixString(16).padLeft(
          8, '0')}),
              child: Center(child: Text('${widget.text}')),
            ) // ID: ${widget.id}''';
    }
    return 'SizedBox.shrink() // ID: ${widget.id}';
  }

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

  List<WidgetData> parseCodeToWidgets(String code) {
    List<WidgetData> parsedWidgets = [];
    RegExp widgetRegex = RegExp(
        r'''Positioned\(\s*'''
        r'''left:\s*([\d.]+),\s*'''
        r'''top:\s*([\d.]+),\s*'''
        r'''child:\s*(Container|ElevatedButton)\('''
        r'''(?:[^)]+)\)'''
        r'''.*?\/\/\s*ID:\s*([a-f0-9-]+)''',
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
      RegExp textRegex = RegExp(r'''Text\(['"](.+?)['"]''');
      RegExp colorRegex = RegExp(r'''Color\(0x([0-9A-Fa-f]+)\)''');
      RegExp sizeRegex = RegExp(
          r'''(?:width|fixedSize: Size)\(([\d.]+),\s*([\d.]+)\)''');

      String text = textRegex.firstMatch(widgetContent)?.group(1) ?? '';
      Color color = Color(int.parse(
          colorRegex.firstMatch(widgetContent)?.group(1) ?? 'FF000000',
          radix: 16));
      double width = double.parse(
          sizeRegex.firstMatch(widgetContent)?.group(1) ?? '100');
      double height = double.parse(
          sizeRegex.firstMatch(widgetContent)?.group(2) ?? '50');

      print(
          "Parsed widget - ID: $id, Type: $type, Position: ($left, $top), Text: $text");

      parsedWidgets.add(WidgetData(
        id: id,
        type: type,
        position: Offset(left, top),
        width: width,
        height: height,
        color: color,
        text: text,
      ));
    }

    if (parsedWidgets.isEmpty) {
      print("No widgets parsed from code.");
    }

    return parsedWidgets;
  }

}