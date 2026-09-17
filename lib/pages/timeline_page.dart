import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/app_strings.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      body: FutureBuilder(
        future: supabase.from('check_ins').select('*, words(title)').order('check_in_date', ascending: false),
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
              final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(item['check_in_date']));
              final wordTitle = item['words'] != null ? item['words']['title'] : '???';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.favorite, color: Color(0xFFFF7B9C), size: 20),
                        Container(width: 2, height: 50, color: const Color(0xFFFFC2D1)),
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
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Text('${AppStrings.triggeredCode}$wordTitle', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            if (item['note'] != null && item['note'].toString().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('${AppStrings.noteLabel}${item['note']}', style: const TextStyle(fontSize: 14)),
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