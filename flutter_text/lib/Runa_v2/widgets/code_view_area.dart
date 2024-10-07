import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/results.dart';
import '../providers/widget_provider.dart';
import '../providers/code_import_export_provider.dart';
import '../models/widget_data.dart';

class CodeViewArea extends StatefulWidget {
  const CodeViewArea({super.key});

  @override
  _CodeViewAreaState createState() => _CodeViewAreaState();
}

class _CodeViewAreaState extends State<CodeViewArea> {
  late TextEditingController _controller;
  String _errorText = '';
  bool _isUserEditing = false;

  @override
  void initState() {
    super.initState();
    final codeProvider = Provider.of<CodeImportExportProvider>(context, listen: false);
    _controller = TextEditingController(text: codeProvider.generateFullDartCode());
    _controller.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onCodeChanged);
    _controller.dispose();
    super.dispose();
  }

  String _validateDartCode(String code) {
    try {
      ParseStringResult result = parseString(
        content: code,
        throwIfDiagnostics: false,
      );
      if (result.errors.isEmpty) {
        return '';
      } else {
        return result.errors.map((e) => e.toString()).join('\n');
      }
    } catch (e) {
      return 'Invalid Dart code: $e';
    }
  }

  //코드에 따라 변경
  void _onCodeChanged() {
    if (!_isUserEditing) return;

    final code = _controller.text;
    final newErrorText = _validateDartCode(code);

    setState(() {
      _errorText = newErrorText;
    });

    if (newErrorText.isEmpty) {
      final widgetProvider = Provider.of<WidgetProvider>(context, listen: false);
      final codeProvider = Provider.of<CodeImportExportProvider>(context, listen: false);

      List<WidgetData> newWidgets = codeProvider.parseCodeToWidgets(code);
      print("Parsed widgets from code: ${newWidgets.length}");

      if (newWidgets.isNotEmpty) {
        widgetProvider.updateWidgetsFromCode(newWidgets);
          print("Widgets updated successfully");
      } else {
        print("No widgets parsed from code. Keeping existing widgets.");

      }
    } else {
      // 코드에 오류가 있을 경우 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error in code: $newErrorText')),
      );
    }
  }

  void _updateCodeFromWidgets() {
    final codeProvider = Provider.of<CodeImportExportProvider>(context, listen: false);
    final newCode = codeProvider.generateFullDartCode();
    if (_controller.text != newCode) {
      _controller.text = newCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WidgetProvider>(
      builder: (context, widgetProvider, child) {
        // 위젯이 변경될 때마다 코드 업데이트
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isUserEditing) {
            _updateCodeFromWidgets();
          }
        });

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        setState(() {
                          _isUserEditing = hasFocus;
                        });
                        if (!hasFocus) {
                          _updateCodeFromWidgets();
                        }
                      },
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          errorText: _errorText.isNotEmpty ? _errorText : null,
                        ),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_errorText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorText,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}