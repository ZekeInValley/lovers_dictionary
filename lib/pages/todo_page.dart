import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_strings.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _supabase = Supabase.instance.client;

  // 新增/修改 心愿弹窗
  void _showTodoDialog([Map<String, dynamic>? todo]) {
    final titleController = TextEditingController(text: todo?['title'] ?? '');
    final isEditing = todo != null;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEditing ? '编辑心愿' : AppStrings.addTodo),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: AppStrings.todoInput,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                if (isEditing) {
                  await _supabase
                      .from('todos')
                      .update({'title': titleController.text})
                      .eq('id', todo['id']);
                } else {
                  await _supabase.from('todos').insert({
                    'title': titleController.text,
                    'is_completed': false,
                  });
                }

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                setState(() {});
              }
            },
            child: Text(isEditing ? AppStrings.save : AppStrings.wishBtn),
          ),
        ],
      ),
    );
  }

  // 删除确认弹窗
  void _deleteTodo(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除心愿'),
        content: const Text('确定要删除这个心愿项吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await _supabase.from('todos').delete().eq('id', id);
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              setState(() {});
            },
            child: const Text('删除', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTodoStatus(int todoId, bool currentStatus) async {
    await _supabase
        .from('todos')
        .update({'is_completed': !currentStatus})
        .eq('id', todoId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _supabase
            .from('todos')
            .select()
            .order('is_completed', ascending: true)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final todos = snapshot.data as List<dynamic>;
          if (todos.isEmpty) {
            return Center(
              child: Text(AppStrings.emptyTodo),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final item = todos[index];
              final bool isCompleted = item['is_completed'] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isCompleted ? const Color(0xFFFAF0F2) : Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: IconButton(
                    icon: Icon(
                      isCompleted ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xFFFF7B9C),
                      size: 28,
                    ),
                    onPressed: () => _toggleTodoStatus(item['id'], isCompleted),
                  ),
                  title: Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                      color: isCompleted ? Colors.grey : Colors.black87,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCompleted)
                        Chip(
                          label: Text(AppStrings.unlocked, style: const TextStyle(fontSize: 11, color: Color(0xFFFF7B9C))),
                          backgroundColor: const Color(0xFFFFE5EC),
                          side: BorderSide.none,
                        ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showTodoDialog(item);
                          } else if (value == 'delete') {
                            _deleteTodo(item['id']);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('编辑'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                SizedBox(width: 8),
                                Text('删除', style: TextStyle(color: Colors.redAccent)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTodoDialog(),
        backgroundColor: const Color(0xFFFF7B9C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}