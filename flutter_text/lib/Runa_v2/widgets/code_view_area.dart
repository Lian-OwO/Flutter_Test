import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/widget_provider.dart';

class CodeViewArea extends StatelessWidget {
  const CodeViewArea({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetProvider>(context);

    // 모든 위젯의 Dart 코드 생성
    final dartCode = provider.widgets.map((widget) => widget.toDartCode()).join('\n');

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,  // 화면 전체 높이로 설정
            ),
            child: Align(
              alignment: Alignment.topLeft,  // 텍스트를 상단에 정렬
              child: Text(
                dartCode.isNotEmpty ? dartCode : '위젯 편집 시 코드 생성',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
