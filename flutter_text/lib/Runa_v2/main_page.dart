import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/editor_panel.dart';
import 'widgets/preview_area.dart';
import 'widgets/property_panel.dart';
import 'providers/widget_provider.dart';
import 'widgets/code_view_area.dart';


class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final widgetProvider = Provider.of<WidgetProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('V2 Test'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () {
              widgetProvider.toggleView();  // 미리보기/코드 전환
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              widgetProvider.togglePanelVisibility();  // 편집 패널 가시성 토글
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const Expanded(flex: 1, child: EditorPanel()),  // 위젯 편집 영역
                Expanded(
                  flex: widgetProvider.isPanelVisible ? 3 : 4,
                  child: widgetProvider.showCode
                      ? const CodeViewArea()  // 코드 뷰 영역
                      : const PreviewArea(),  // 미리보기 영역
                ),
                if (widgetProvider.isPanelVisible)  // 패널이 보일 때만 PropertyPanel을 렌더링
                  const Expanded(
                    flex: 1,
                    child: PropertyPanel(),  // PropertyPanel 인자 없이 사용
                  ),
              ],
            ),
          ),
          //우측하단 코드 전환 버튼
          // Container(
          //   color: Colors.grey[200],
          //   padding: const EdgeInsets.all(8.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       ElevatedButton(
          //         onPressed: () {
          //           widgetProvider.toggleView();  // 코드/미리보기 전환 버튼
          //         },
          //         child: Text(
          //           widgetProvider.showCode ? '미리보기로 전환' : '코드로 전환',
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
