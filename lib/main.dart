import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // 添加這行
import 'package:provider/provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';
import 'ui/theme/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();  // 添加這行

  // 添加這段代碼以限制只能使用直式模式
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 從 Provider 獲取當前主題
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: '停車繳費查詢',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false, // 去除右上角的 debug 標籤
    );
  }
}