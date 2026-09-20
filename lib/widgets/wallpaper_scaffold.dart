import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_strings.dart';

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
  String? _wallpaperPath;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 优先使用 'user_space_name'，兼容旧 key 'space_name'
    final savedSpaceName = prefs.getString('user_space_name') ?? prefs.getString('space_name') ?? '';
    // 优先使用 'anniversary_date'，兼容旧 key 'start_date'
    final savedDateStr = prefs.getString('anniversary_date') ?? prefs.getString('start_date');
    final savedWallpaper = prefs.getString('wallpaper_path');

    setState(() {
      _spaceName = savedSpaceName;
      _nameController.text = _spaceName;
      _wallpaperPath = savedWallpaper;
      if (savedDateStr != null) {
        _startDate = DateTime.tryParse(savedDateStr) ?? _startDate;
      }
    });
  }

  Future<void> _saveStartDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('anniversary_date', date.toIso8601String());
    setState(() {
      _startDate = date;
    });
  }

  Future<void> _saveSpaceName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_space_name', name);
    setState(() {
      _spaceName = name;
    });
  }

  Future<void> _pickWallpaper() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '裁剪设置壁纸',
            toolbarColor: Colors.pink,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
          IOSUiSettings(
            title: '裁剪设置壁纸',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
        ],
      );

      final finalPath = croppedFile?.path ?? image.path;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('wallpaper_path', finalPath);
      setState(() {
        _wallpaperPath = finalPath;
      });
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

    // 校验本地图片文件是否存在
    final bool hasWallpaper = _wallpaperPath != null &&
        _wallpaperPath!.isNotEmpty &&
        File(_wallpaperPath!).existsSync();

    return Container(
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        image: hasWallpaper
            ? DecorationImage(
                image: FileImage(File(_wallpaperPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 顶部独立保留退出登录按钮
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

              // 空间名称输入/展示
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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

              // 精致相爱天数卡片
              GestureDetector(
                onTap: _selectDate,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white.withValues(alpha: 0.9),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.loveDaysTitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
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
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 居中显示的【每日电影台词卡片】
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
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
                        AppStrings.dailyQuote,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.6,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
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
  }
}