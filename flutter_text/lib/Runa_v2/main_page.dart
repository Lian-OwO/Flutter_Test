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
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: EditorPanel(),  // 위젯 편집 영역
                ),
                Container(
                  width: 1,
                  color: Colors.grey[300],
                ),  // 세로 구분선 추가
                Expanded(
                  flex: 3,  // 미리보기 영역 비율 고정
                  child: widgetProvider.showCode
                      ? const CodeViewArea()  // 코드 뷰 영역
                      : PreviewArea(isEditPanelOpen: true),  // 항상 열려 있는 프로퍼티 패널과 함께 미리보기 영역을 보여줌
                ),
                Container(
                  width: 1,
                  color: Colors.grey[300],
                ),  // 세로 구분선 추가
                const Expanded(
                  flex: 1,  // 프로퍼티 패널 항상 렌더링
                  child: PropertyPanel(),  // 속성 편집 패널
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
