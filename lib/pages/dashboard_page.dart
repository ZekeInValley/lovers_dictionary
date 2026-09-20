import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_strings.dart';
import '../main.dart';

class DashboardPage extends StatefulWidget {
  final Function(bool) onLanguageChanged;
  final VoidCallback onLogout;

  const DashboardPage({
    super.key,
    required this.onLanguageChanged,
    required this.onLogout,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 100));
  String _spaceName = '';
  final TextEditingController _nameController = TextEditingController();

  // 默认双语台词备用
  String _quoteZh = '“世界上有那么多的城镇，城镇中有那么多的酒馆，她却走进了我的。” ——《卡萨布兰卡》';
  String _quoteEn = '"Of all the gin joints in all the towns in all the world, she walks into mine." — Casablanca';

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _fetchDailyQuote();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _spaceName = prefs.getString('space_name') ?? '';
        _nameController.text = _spaceName;
        final savedDateStr = prefs.getString('start_date');
        if (savedDateStr != null) {
          _startDate = DateTime.tryParse(savedDateStr) ?? _startDate;
        }
      });
    }
  }

  /// 获取每日台词：优先从 Supabase 读当天数据，确保所有用户 100% 看到同一条台词
  Future<void> _fetchDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // 1. 本地缓存命中，直接使用
    if (prefs.getString('daily_quote_date') == todayStr) {
      if (mounted) {
        setState(() {
          _quoteZh = prefs.getString('daily_quote_zh') ?? _quoteZh;
          _quoteEn = prefs.getString('daily_quote_en') ?? _quoteEn;
        });
      }
      return;
    }

    final supabase = Supabase.instance.client;

    try {
      // 2. 尝试从 Supabase 查找今天是否有全局台词记录
      final response = await supabase
          .from('daily_quotes')
          .select()
          .eq('date', todayStr)
          .maybeSingle();

      if (response != null) {
        // Supabase 已有今天台词，直接使用
        final zh = response['quote_zh'] as String;
        final en = response['quote_en'] as String;

        _updateAndCacheQuote(prefs, todayStr, zh, en);
        return;
      }

      // 3. 如果 Supabase 里今天还没有台词（首位用户），调用 API 请求并翻译
      final apiRes = await http
          .get(Uri.parse('https://v1.hitokoto.cn/?c=h&c=a'))
          .timeout(const Duration(seconds: 4));

      if (apiRes.statusCode == 200) {
        final data = json.decode(apiRes.body);
        final String hitokoto = data['hitokoto'] ?? '';
        final String from = data['from'] ?? '';

        if (hitokoto.isNotEmpty) {
          final zh = from.isNotEmpty ? '“$hitokoto” ——《$from》' : '“$hitokoto”';
          String en = '';

          try {
            // 将台词与影视名组合进行翻译
            final fullText = from.isNotEmpty ? '$hitokoto — $from' : hitokoto;
            final transRes = await http.get(
              Uri.parse('https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(fullText)}&langpair=zh|en'),
            ).timeout(const Duration(seconds: 4));

            if (transRes.statusCode == 200) {
              final transData = json.decode(transRes.body);
              final String translatedText = transData['responseData']?['translatedText'] ?? '';

              if (translatedText.isNotEmpty) {
                if (from.isNotEmpty && translatedText.contains('—')) {
                  final parts = translatedText.split('—');
                  en = '"${parts[0].trim()}" — "${parts.sublist(1).join('—').trim()}"';
                } else {
                  en = '"$translatedText"';
                }
              }
            }
          } catch (_) {}

          if (en.isEmpty) en = _quoteEn;

          // 将今天生成的台词写入 Supabase，供后续所有其他用户读取
          try {
            await supabase.from('daily_quotes').insert({
              'date': todayStr,
              'quote_zh': zh,
              'quote_en': en,
            });
          } catch (e) {
            debugPrint("写入 Supabase 冲突或失败: $e");
          }

          _updateAndCacheQuote(prefs, todayStr, zh, en);
        }
      }
    } catch (e) {
      debugPrint("获取每日台词失败，使用本地默认台词: $e");
    }
  }

  void _updateAndCacheQuote(SharedPreferences prefs, String dateStr, String zh, String en) {
    if (mounted) {
      setState(() {
        _quoteZh = zh;
        _quoteEn = en;
      });
    }
    prefs.setString('daily_quote_date', dateStr);
    prefs.setString('daily_quote_zh', zh);
    prefs.setString('daily_quote_en', en);
  }

  Future<void> _saveStartDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('start_date', date.toIso8601String());
    setState(() => _startDate = date);
  }

  Future<void> _saveSpaceName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('space_name', name);
    setState(() => _spaceName = name);
  }

  Future<void> _pickWallpaper() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: AppStrings.isChinese ? '裁剪适配壁纸' : 'Crop Wallpaper',
              toolbarColor: Colors.pink,
              toolbarWidgetColor: Colors.white,
            ),
            IOSUiSettings(
              title: AppStrings.isChinese ? '裁剪适配壁纸' : 'Crop Wallpaper',
            ),
          ],
        );

        final finalPath = croppedFile?.path ?? image.path;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('wallpaper_path', finalPath);
        wallpaperPathNotifier.value = finalPath;
      }
    } catch (e) {
      debugPrint("选择壁纸出错: $e");
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      _saveStartDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInLove = DateTime.now().difference(_startDate).inDays + 1;

    return ValueListenableBuilder<bool>(
      valueListenable: AppStrings.isChineseNotifier,
      builder: (context, isChinese, child) {
        final currentQuote = isChinese ? _quoteZh : _quoteEn;

        return Container(
          color: Colors.pink.shade50,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 退出登录按钮
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.pink),
                      tooltip: AppStrings.logout,
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        widget.onLogout();
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 空间名称卡片（浅粉底色 Color(0xFFFFF5F7)）
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: const Color(0xFFFFF5F7),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: AppStrings.spaceNameHint,
                          icon: const Icon(Icons.favorite, color: Colors.pink),
                        ),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade900,
                        ),
                        onChanged: _saveSpaceName,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 相爱天数卡片（白底）
                  GestureDetector(
                    onTap: _selectDate,
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                        child: Column(
                          children: [
                            Text(
                              AppStrings.loveDaysTitle,
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$daysInLove',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'DAYS',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pinkAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.changeStartDate,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 爱的对白卡片
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Colors.pink.shade100.withValues(alpha: 0.95),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.format_quote, color: Colors.pink, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.dailyQuoteTitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentQuote,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 自定义壁纸按钮
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.pink),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _pickWallpaper,
                    icon: const Icon(Icons.photo, color: Colors.pink),
                    label: Text(
                      AppStrings.changeWallpaper,
                      style: const TextStyle(color: Colors.pink, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}