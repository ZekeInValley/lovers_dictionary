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

  void _showAddTodoDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.addTodo),
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
                await _supabase.from('todos').insert({
                  'title': titleController.text,
                  'is_completed': false,
                });

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                setState(() {});
              }
            },
            child: Text(AppStrings.wishBtn),
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
                  trailing: isCompleted
                      ? Chip(
                          label: Text(AppStrings.unlocked, style: const TextStyle(fontSize: 11, color: Color(0xFFFF7B9C))),
                          backgroundColor: const Color(0xFFFFE5EC),
                          side: BorderSide.none,
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        backgroundColor: const Color(0xFFFF7B9C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}