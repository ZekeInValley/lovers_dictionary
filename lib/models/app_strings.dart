class AppStrings {
  static bool isChinese = true;

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

  // --- 固定的每日电影台词逻辑 ---
  static const List<Map<String, String>> _quotes = [
    {
      'zh': '“世界上有那么多的城镇，城镇中有那么多的酒馆，她却走进了我的。” ——《卡萨布兰卡》',
      'en': '"Of all the gin joints in all the towns in all the world, she walks into mine." — Casablanca',
    },
    {
      'zh': '“对我来说，你是完美的。” ——《真爱至上》',
      'en': '"To me, you are perfect." — Love Actually',
    },
    {
      'zh': '“我跨越了时间的瀚海来寻找你。” ——《吸血惊情四百年》',
      'en': '"I have crossed oceans of time to find you." — Dracula',
    },
    {
      'zh': '“你让我想要成为一个更好的人。” ——《尽善尽美》',
      'en': '"You make me want to be a better man." — As Good as It Gets',
    },
    {
      'zh': '“爱你是我做过最简单的事。” ——《傲慢与偏见》',
      'en': '"You have bewitched me, body and soul, and I love... I love... I love you." — Pride & Prejudice',
    },
    {
      'zh': '“遇到你之前，我从未想过结婚。” ——《泰坦尼克号》',
      'en': '"Winning that ticket, Rose, was the best thing that ever happened to me." — Titanic',
    },
    {
      'zh': '“如果你活到一百岁，我希望活到一百岁减一天，这样我就不用过没有你的日子。” ——《小熊维尼》',
      'en': '"If you live to be a hundred, I want to live to be a hundred minus one day so I never have to live without you." — Winnie the Pooh',
    },
  ];

  static String get dailyQuote {
    final now = DateTime.now();
    // 使用 年+月+日 生成固定的整数 key
    final dateSeed = now.year * 10000 + now.month * 100 + now.day;
    final index = dateSeed % _quotes.length;
    final quoteMap = _quotes[index];
    return isChinese ? quoteMap['zh']! : quoteMap['en']!;
  }
}