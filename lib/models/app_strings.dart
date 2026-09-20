import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppStrings {
  // 使用 ValueNotifier 实现语言状态全局可监听
  static ValueNotifier<bool> isChineseNotifier = ValueNotifier<bool>(true);

  // 快捷获取与设置当前语言状态
  static bool get isChinese => isChineseNotifier.value;

  // 补全 setter 方法，解决 "There isn't a setter named 'isChinese'" 报错
  static set isChinese(bool value) {
    isChineseNotifier.value = value;
  }

  // 切换语言方法
  static void toggleLanguage() {
    isChineseNotifier.value = !isChineseNotifier.value;
  }

  // 默认备用台词（当网络请求失败或首次加载时使用）
  static String _dailyQuoteZh = '“世界上有那么多的城镇，城镇中有那么多的酒馆，她却走进了我的。” ——《卡萨布兰卡》';
  static String _dailyQuoteEn = '"Of all the gin joints in all the towns in all the world, she walks into mine." — Casablanca';

  // 获取当前语言下的每日台词
  static String get dailyQuote => isChinese ? _dailyQuoteZh : _dailyQuoteEn;

  /// 外部自动获取每日台词（使用 Hitokoto API + 自动翻译英文 + 本地天级缓存）
  static Future<void> fetchDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    // 提取当前日期字符串，形如 "2026-09-20"
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastFetchDate = prefs.getString('daily_quote_date');

    // 1. 如果今天已经请求并缓存过，直接读取本地数据
    if (lastFetchDate == todayStr) {
      _dailyQuoteZh = prefs.getString('daily_quote_zh') ?? _dailyQuoteZh;
      _dailyQuoteEn = prefs.getString('daily_quote_en') ?? _dailyQuoteEn;
      return;
    }

    // 2. 今天尚未请求，发起 Hitokoto API 请求（请求 c=h 影视，c=a 动画）
    try {
      final response = await http
          .get(Uri.parse('https://v1.hitokoto.cn/?c=h&c=a'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String hitokoto = data['hitokoto'] ?? '';
        final String from = data['from'] ?? '';

        if (hitokoto.isNotEmpty) {
          final formattedQuoteZh = from.isNotEmpty ? '“$hitokoto” ——《$from》' : '“$hitokoto”';
          _dailyQuoteZh = formattedQuoteZh;

          // 自动翻译为英文
          String translatedEn = '';
          try {
            final transRes = await http.get(
              Uri.parse('https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(hitokoto)}&langpair=zh|en'),
            ).timeout(const Duration(seconds: 5));

            if (transRes.statusCode == 200) {
              final transData = json.decode(transRes.body);
              final String translatedText = transData['responseData']?['translatedText'] ?? '';
              if (translatedText.isNotEmpty) {
                translatedEn = from.isNotEmpty ? '"$translatedText" — "$from"' : '"$translatedText"';
              }
            }
          } catch (e) {
            debugPrint('翻译每日台词失败，使用备用格式: $e');
          }

          _dailyQuoteEn = translatedEn.isNotEmpty ? translatedEn : formattedQuoteZh;

          // 缓存到本地，避免一天内重复发请求
          await prefs.setString('daily_quote_date', todayStr);
          await prefs.setString('daily_quote_zh', _dailyQuoteZh);
          await prefs.setString('daily_quote_en', _dailyQuoteEn);
        }
      }
    } catch (e) {
      debugPrint('获取 Hitokoto 每日台词失败，使用本地默认台词: $e');
    }
  }

  // 基础与通用
  static String get appTitle => isChinese ? '情侣词典' : 'Lovers Dictionary';
  static String get currentUser => isChinese ? '当前登录' : 'Logged in as';
  static String get logout => isChinese ? '退出登录' : 'Sign Out';
  static String get cancel => isChinese ? '取消' : 'Cancel';
  static String get save => isChinese ? '保存' : 'Save';
  static String get confirm => isChinese ? '确认' : 'Confirm';

  // 导航栏
  static String get navHome => isChinese ? '首页' : 'Home';
  static String get navDict => isChinese ? '词典' : 'Dictionary';
  static String get navTimeline => isChinese ? '时光' : 'Timeline';
  static String get navShare => isChinese ? '心声' : 'Share';
  static String get navTodo => isChinese ? '清单' : 'Todo';

  // 首页与仪表盘
  static String get keepLoggedIn => isChinese ? '保持登录 30 天' : 'Keep me logged in';
  static String get loveDaysTitle => isChinese ? '我们相爱的第' : 'We have been in love for';
  static String get changeStartDate => isChinese ? '点击修改相恋纪念日' : 'Tap to change start date';
  static String get spaceNameHint => isChinese ? '给我们的秘密基地起个名字吧' : 'Give your lover space a name';
  static String get changeWallpaper => isChinese ? '自定义浪漫壁纸' : 'Custom Wallpaper';
  static String get dailyQuoteTitle => isChinese ? '爱的对白' : 'Daily Movie Quote';
  static String get checkIn => isChinese ? '打卡' : 'Check In';
  static String get checkInNote => isChinese ? '打卡备注' : 'Check-in Note';
  static String get checkInSuccess => isChinese ? '打卡成功！' : 'Check-in Successful!';

  // 词典页面 (Dictionary)
  static String get addWord => isChinese ? '添加新词条' : 'Add New Word';
  static String get wordTitle => isChinese ? '词条名称' : 'Word';
  static String get meaning => isChinese ? '专属释义' : 'Meaning';
  static String get story => isChinese ? '背后故事' : 'Story';
  static String get emptyDict => isChinese ? '还没有专属词条，快去创建一个吧！' : 'No words yet, add your first one!';
  static String get realMeaningLabel => isChinese ? '【真正含义】' : '[Real Meaning]';
  static String get storyLabel => isChinese ? '【典故起源】' : '[Origin Story]';

  // 时光页面 (Timeline)
  static String get emptyTimeline => isChinese ? '时光轴空空如也，去记录第一条打卡吧！' : 'Timeline is empty!';
  static String get triggeredCode => isChinese ? '解密暗号' : 'Trigger Code';
  static String get noteLabel => isChinese ? '随手记' : 'Note';
  static String get editDate => isChinese ? '修改日期' : 'Edit Date';
  static String get delete => isChinese ? '删除' : 'Delete';
  static String get confirmDeleteTitle => isChinese ? '确认删除' : 'Confirm Delete';
  static String get confirmDeleteContent => isChinese ? '确定要删除这条打卡记录吗？' : 'Are you sure you want to delete this check-in?';
  static String get deleteSuccess => isChinese ? '删除成功' : 'Deleted successfully';
  static String get deleteFailed => isChinese ? '删除失败' : 'Delete failed';
  static String get updateSuccess => isChinese ? '日期更新成功' : 'Date updated successfully';
  static String get updateFailed => isChinese ? '更新失败' : 'Update failed';

  // 心声页面 (Share)
  static String get addShare => isChinese ? '发布心声' : 'New Post';
  static String get shareContent => isChinese ? '想对TA说点什么...' : 'Share your thoughts...';
  static String get shareLink => isChinese ? '链接 (可选)' : 'Link (Optional)';
  static String get shareImage => isChinese ? '图片链接 (可选)' : 'Image URL (Optional)';
  static String get sharedSuccess => isChinese ? '发布成功！' : 'Posted Successfully!';
  static String get emptyShared => isChinese ? '暂无已分享内容' : 'No shared posts';
  static String get emptyPending => isChinese ? '暂无待解锁心声' : 'No pending posts';
  static String get markShared => isChinese ? '标记为已分享' : 'Mark as Shared';
  static String get tabPending => isChinese ? '待解锁' : 'Pending';
  static String get tabShared => isChinese ? '已解锁' : 'Shared';

  // 清单页面 (Todo)
  static String get addTodo => isChinese ? '添加愿望清单' : 'Add Wish';
  static String get todoInput => isChinese ? '想一起做的事情...' : 'Something to do together...';
  static String get wishBtn => isChinese ? '许愿' : 'Make Wish';
  static String get emptyTodo => isChinese ? '清单还是空的，快把浪漫小事列出来吧！' : 'Todo list is empty!';
  static String get unlocked => isChinese ? '已打卡解锁！' : 'Completed!';
}