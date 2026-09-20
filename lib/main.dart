import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/app_strings.dart';
import 'pages/auth_gate.dart';

// 全局语言切换通知器
final ValueNotifier<bool> isChineseNotifier = ValueNotifier<bool>(false);

// 全局壁纸路径通知器（让壁纸在所有页面实时生效）
final ValueNotifier<String?> wallpaperPathNotifier = ValueNotifier<String?>(null);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Supabase
  await Supabase.initialize(
    url: 'https://gqtmxmqungjsqlxfjrdx.supabase.co',
    publishableKey: 'sb_publishable_nwL7Mxj_yaba_eOWJfQk7A_DMjZkk7t',
  );

  // 启动时读取本地缓存的壁纸路径
  final prefs = await SharedPreferences.getInstance();
  wallpaperPathNotifier.value = prefs.getString('wallpaper_path');

  runApp(const LoversDictionaryApp());
}

class LoversDictionaryApp extends StatelessWidget {
  const LoversDictionaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 监听语言切换
    return ValueListenableBuilder<bool>(
      valueListenable: isChineseNotifier,
      builder: (context, isChinese, child) {
        // 同步更新 AppStrings 内部静态状态
        AppStrings.isChinese = isChinese;

        return MaterialApp(
          // ⚠️【关键修复】：绝对不能给 MaterialApp 加 ValueKey，否则切换语言会重置整个 App 路由跳回首页！
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
          // 监听壁纸路径变化，为整个 App 铺上统一背景
          builder: (context, child) {
            return ValueListenableBuilder<String?>(
              valueListenable: wallpaperPathNotifier,
              builder: (context, wallpaperPath, _) {
                final bool hasWallpaper = wallpaperPath != null &&
                    wallpaperPath.isNotEmpty &&
                    File(wallpaperPath).existsSync();

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F7),
                    image: hasWallpaper
                        ? DecorationImage(
                            image: FileImage(File(wallpaperPath)),
                            fit: BoxFit.cover, // 全屏铺满适配
                          )
                        : null,
                  ),
                  child: child,
                );
              },
            );
          },
          home: const AuthGate(),
        );
      },
    );
  }
}