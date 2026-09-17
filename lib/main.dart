import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/app_strings.dart';
import 'pages/auth_gate.dart';

// 全局语言切换通知器
final ValueNotifier<bool> isChineseNotifier = ValueNotifier<bool>(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gqtmxmqungjsqlxfjrdx.supabase.co',
    publishableKey: 'sb_publishable_nwL7Mxj_yaba_eOWJfQk7A_DMjZkk7t',
  );

  runApp(const LoversDictionaryApp());
}

class LoversDictionaryApp extends StatelessWidget {
  const LoversDictionaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isChineseNotifier,
      builder: (context, isChinese, child) {
        // 更新全局状态
        AppStrings.isChinese = isChinese;

        return MaterialApp(
          // 添加 Key：当 isChinese 改变时，强制刷新整个App
          key: ValueKey<bool>(isChinese),
          title: AppStrings.appTitle,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF7B9C),
              primary: const Color(0xFFFF7B9C),
              surface: const Color(0xFFFFF5F7),
            ),
            useMaterial3: true,
          ),
          home: const AuthGate(),
        );
      },
    );
  }
}