import 'package:flutter/material.dart';
import '../main.dart';
import '../models/app_strings.dart';
import 'dashboard_page.dart';
import 'dictionary_page.dart';
import 'timeline_page.dart';
import 'share_page.dart';
import 'todo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardPage(
        onLanguageChanged: (isChinese) {
          setState(() {
            isChineseNotifier.value = isChinese;
          });
        },
        onLogout: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      const DictionaryPage(),
      const TimelinePage(),
      const SharePage(),
      const TodoPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      // 自定义精致顶部导航栏
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF7B9C).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左侧 App 浪漫图标与标题
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFFF7B9C),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppStrings.appTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),

                  // 右侧胶囊风格语言切换按钮
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isChineseNotifier.value = !isChineseNotifier.value;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFF7B9C).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.language_rounded,
                              color: Color(0xFFFF7B9C),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isChineseNotifier.value ? 'EN' : '中文',
                              style: const TextStyle(
                                color: Color(0xFFFF7B9C),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // 主体多页面缓存栈
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // 高颜值圆角底部导航栏
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: NavigationBar(
            height: 66,
            elevation: 0,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFFFF0F3),
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined, color: Color(0xFF8E8E93)),
                selectedIcon: const Icon(Icons.home_rounded, color: Color(0xFFFF7B9C)),
                label: AppStrings.navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined, color: Color(0xFF8E8E93)),
                selectedIcon: const Icon(Icons.menu_book_rounded, color: Color(0xFFFF7B9C)),
                label: AppStrings.navDict,
              ),
              NavigationDestination(
                icon: const Icon(Icons.favorite_outline_rounded, color: Color(0xFF8E8E93)),
                selectedIcon: const Icon(Icons.favorite_rounded, color: Color(0xFFFF7B9C)),
                label: AppStrings.navTimeline,
              ),
              NavigationDestination(
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF8E8E93)),
                selectedIcon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFFFF7B9C)),
                label: AppStrings.navShare,
              ),
              NavigationDestination(
                icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF8E8E93)),
                selectedIcon: const Icon(Icons.check_circle_rounded, color: Color(0xFFFF7B9C)),
                label: AppStrings.navTodo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}