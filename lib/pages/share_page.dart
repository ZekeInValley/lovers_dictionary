import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/app_strings.dart';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final _supabase = Supabase.instance.client;

  // 新增/编辑 心声弹窗
  void _showShareDialog([Map<String, dynamic>? item]) {
    final contentController = TextEditingController(text: item?['content'] ?? '');
    final linkController = TextEditingController(text: item?['link_url'] ?? '');
    final imageController = TextEditingController(text: item?['image_url'] ?? '');
    final isEditing = item != null;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEditing ? (isChineseNotifier.value ? '编辑心声' : 'Edit Post') : AppStrings.addShare),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                maxLines: 3,
                decoration: InputDecoration(labelText: AppStrings.shareContent),
              ),
              TextField(
                controller: linkController,
                decoration: InputDecoration(labelText: AppStrings.shareLink),
              ),
              TextField(
                controller: imageController,
                decoration: InputDecoration(labelText: AppStrings.shareImage),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (contentController.text.isNotEmpty ||
                  linkController.text.isNotEmpty ||
                  imageController.text.isNotEmpty) {
                final data = {
                  'content': contentController.text,
                  'link_url': linkController.text,
                  'image_url': imageController.text,
                };

                if (isEditing) {
                  await _supabase.from('shares').update(data).eq('id', item['id']);
                } else {
                  await _supabase.from('shares').insert({
                    ...data,
                    'is_shared': false,
                  });
                }

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                setState(() {});
              }
            },
            child: Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  // 删除确认
  void _deleteShare(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isChineseNotifier.value ? '删除心声' : 'Delete Post'),
        content: Text(isChineseNotifier.value ? '确定要删除这条心声吗？' : 'Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await _supabase.from('shares').delete().eq('id', id);
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              setState(() {});
            },
            child: Text(isChineseNotifier.value ? '删除' : 'Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsShared(int shareId) async {
    await _supabase.from('shares').update({'is_shared': true}).eq('id', shareId);
    setState(() {});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.sharedSuccess)),
    );
  }

  Widget _buildShareList(bool isShared) {
    return FutureBuilder(
      future: _supabase
          .from('shares')
          .select()
          .eq('is_shared', isShared)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data as List<dynamic>;
        if (items.isEmpty) {
          return Center(
            child: Text(
              isShared ? AppStrings.emptyShared : AppStrings.emptyPending,
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final dateStr = DateFormat('MM-dd HH:mm').format(DateTime.parse(item['created_at']));
            final content = item['content'] ?? '';
            final linkUrl = item['link_url'] ?? '';
            final imageUrl = item['image_url'] ?? '';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isShared)
                              TextButton.icon(
                                onPressed: () => _markAsShared(item['id']),
                                icon: const Icon(Icons.check_circle_outline, size: 18),
                                label: Text(AppStrings.markShared),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFFF7B9C),
                                ),
                              ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showShareDialog(item);
                                } else if (value == 'delete') {
                                  _deleteShare(item['id']);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit_outlined, size: 18),
                                      const SizedBox(width: 8),
                                      Text(isChineseNotifier.value ? '编辑' : 'Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                      const SizedBox(width: 8),
                                      Text(
                                        isChineseNotifier.value ? '删除' : 'Delete',
                                        style: const TextStyle(color: Colors.redAccent),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (content.toString().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(content, style: const TextStyle(fontSize: 16)),
                    ],
                    if (linkUrl.toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SelectableText(
                        '🔗 Link: $linkUrl',
                        style: const TextStyle(color: Colors.blue, fontSize: 13),
                      ),
                    ],
                    if (imageUrl.toString().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Text('（Image load failed）', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ValueListenableBuilder<bool>(
        valueListenable: isChineseNotifier,
        builder: (context, _, __) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                indicatorColor: const Color(0xFFFF7B9C),
                labelColor: const Color(0xFFFF7B9C),
                tabs: [
                  Tab(text: AppStrings.tabPending),
                  Tab(text: AppStrings.tabShared),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildShareList(false),
                _buildShareList(true),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showShareDialog(),
              backgroundColor: const Color(0xFFFF7B9C),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}