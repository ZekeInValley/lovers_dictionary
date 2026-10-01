import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../models/app_strings.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final _supabase = Supabase.instance.client;

  // 增加/编辑 弹窗（传入 item 即为编辑模式，传 null 即为新增模式）
  void _showWordDialog([Map<String, dynamic>? word]) {
    final titleController = TextEditingController(text: word?['title'] ?? '');
    final meaningController = TextEditingController(text: word?['meaning'] ?? '');
    final storyController = TextEditingController(text: word?['story'] ?? '');
    final isEditing = word != null;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEditing 
            ? (isChineseNotifier.value ? '编辑词条' : 'Edit Word') 
            : AppStrings.addWord),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: AppStrings.wordTitle),
            ),
            TextField(
              controller: meaningController,
              decoration: InputDecoration(labelText: AppStrings.meaning),
            ),
            TextField(
              controller: storyController,
              decoration: InputDecoration(labelText: AppStrings.story),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && meaningController.text.isNotEmpty) {
                final data = {
                  'title': titleController.text,
                  'meaning': meaningController.text,
                  'story': storyController.text,
                };

                if (isEditing) {
                  await _supabase.from('words').update(data).eq('id', word['id']);
                } else {
                  await _supabase.from('words').insert(data);
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

  // 删除确认弹窗
  void _deleteWord(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isChineseNotifier.value ? '删除词条' : 'Delete Word'),
        content: Text(isChineseNotifier.value ? '确定要删除这个词条吗？' : 'Are you sure you want to delete this word?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await _supabase.from('words').delete().eq('id', id);
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              setState(() {});
            },
            child: Text(
              isChineseNotifier.value ? '删除' : 'Delete',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _checkInWord(int wordId, String wordTitle) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${AppStrings.checkIn}: $wordTitle'),
        content: TextField(
          controller: noteController,
          decoration: InputDecoration(labelText: AppStrings.checkInNote),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await _supabase.from('check_ins').insert({
                'word_id': wordId,
                'note': noteController.text,
              });

              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.checkInSuccess)),
              );
            },
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isChineseNotifier,
      builder: (context, isChinese, _) {
        return Scaffold(
          body: FutureBuilder(
            future: _supabase.from('words').select().order('created_at', ascending: false),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final words = snapshot.data as List<dynamic>;
              if (words.isEmpty) {
                return Center(child: Text(AppStrings.emptyDict));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: words.length,
                itemBuilder: (context, index) {
                  final word = words[index];
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
                              Expanded(
                                child: Text(
                                  word['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF7B9C),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.touch_app_rounded, color: Color(0xFFFF7B9C)),
                                    tooltip: AppStrings.checkIn,
                                    onPressed: () => _checkInWord(word['id'], word['title']),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showWordDialog(word);
                                      } else if (value == 'delete') {
                                        _deleteWord(word['id']);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.edit_outlined, size: 18),
                                            const SizedBox(width: 8),
                                            Text(isChinese ? '编辑' : 'Edit'),
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
                                              isChinese ? '删除' : 'Delete',
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
                          const SizedBox(height: 8),
                          Text('${AppStrings.realMeaningLabel}${word['meaning']}', style: const TextStyle(fontSize: 15)),
                          if (word['story'] != null && word['story'].toString().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text('${AppStrings.storyLabel}${word['story']}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showWordDialog(),
            backgroundColor: const Color(0xFFFF7B9C),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}