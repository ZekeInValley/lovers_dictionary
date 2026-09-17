import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_strings.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final _supabase = Supabase.instance.client;

  void _showAddWordDialog() {
    final titleController = TextEditingController();
    final meaningController = TextEditingController();
    final storyController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.addWord),
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
                await _supabase.from('words').insert({
                  'title': titleController.text,
                  'meaning': meaningController.text,
                  'story': storyController.text,
                });
                
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
                          Text(
                            word['title'],
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF7B9C)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.touch_app_rounded, color: Color(0xFFFF7B9C)),
                            tooltip: AppStrings.checkIn,
                            onPressed: () => _checkInWord(word['id'], word['title']),
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
        onPressed: _showAddWordDialog,
        backgroundColor: const Color(0xFFFF7B9C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}