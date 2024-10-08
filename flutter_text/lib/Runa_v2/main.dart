import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/widget_provider.dart';
import 'providers/drag_drop_provider.dart';  // 드래그앤드랍 프로바이더 추가
import 'providers/code_import_export_provider.dart';//임포트익스포트 프로바이더
import 'main_page.dart'; // 분리된 MainPage 파일

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WidgetProvider()),
        ChangeNotifierProvider(create: (_) => DragAndDropProvider()),  // 드래그앤드랍 프로바이더 추가
        ChangeNotifierProxyProvider<WidgetProvider, CodeImportExportProvider>(
          create: (context) => CodeImportExportProvider(context.read<WidgetProvider>()),
          update: (context, widgetProvider, previous) =>
              CodeImportExportProvider(widgetProvider),
        ),
      ],
      child: MaterialApp(
        title: 'Runa_V2',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MainPage(),
        debugShowCheckedModeBanner: false, // 앱바 디버그 표시 off
      ),
    );
  }
}
