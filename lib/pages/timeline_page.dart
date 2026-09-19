import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/app_strings.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final supabase = Supabase.instance.client;

  // 1. 删除打卡记录
  Future<void> _deleteCheckIn(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.confirmDeleteTitle),
        content: Text(AppStrings.confirmDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase.from('check_ins').delete().eq('id', id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.deleteSuccess)),
          );
          setState(() {}); // 刷新列表
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppStrings.deleteFailed}: $e')),
          );
        }
      }
    }
  }

  // 2. 修改打卡日期（仅选择日期）
  Future<void> _editCheckInDate(String id, DateTime currentDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;

    try {
      await supabase.from('check_ins').update({
        'check_in_date': pickedDate.toUtc().toIso8601String(),
      }).eq('id', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.updateSuccess)),
        );
        setState(() {}); // 刷新列表
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.updateFailed}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: supabase
            .from('check_ins')
            .select('*, words(title)')
            .order('check_in_date', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final checkIns = snapshot.data as List<dynamic>;
          if (checkIns.isEmpty) {
            return Center(child: Text(AppStrings.emptyTimeline));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: checkIns.length,
            itemBuilder: (context, index) {
              final item = checkIns[index];
              final currentDateTime = DateTime.parse(item['check_in_date']);
              // 简化日期格式：只保留 yyyy-MM-dd
              final dateStr = DateFormat('yyyy-MM-dd').format(currentDateTime.toLocal());
              final wordTitle =
                  item['words'] != null ? item['words']['title'] : '???';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.favorite,
                            color: Color(0xFFFF7B9C), size: 20),
                        Container(
                            width: 2, height: 60, color: const Color(0xFFFFC2D1)),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(dateStr,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600])),
                                // 更多菜单按钮：支持多语言
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(Icons.more_vert,
                                        size: 18, color: Colors.grey[600]),
                                    onSelected: (value) {
                                      if (value == 'edit_date') {
                                        _editCheckInDate(
                                            item['id'].toString(),
                                            currentDateTime.toLocal());
                                      } else if (value == 'delete') {
                                        _deleteCheckIn(item['id'].toString());
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'edit_date',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.edit_calendar,
                                                size: 18),
                                            const SizedBox(width: 8),
                                            Text(AppStrings.editDate),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.delete,
                                                color: Colors.red, size: 18),
                                            const SizedBox(width: 8),
                                            Text(AppStrings.delete,
                                                style: const TextStyle(
                                                    color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${AppStrings.triggeredCode}$wordTitle',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            if (item['note'] != null &&
                                item['note'].toString().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('${AppStrings.noteLabel}${item['note']}',
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}