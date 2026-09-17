import 'package:flutter_test/flutter_test.dart';
import 'package:lovers_dictionary/main.dart';

void main() {
  testWidgets('App basic smoke test', (WidgetTester tester) async {
    // 渲染我们的情侣词典 App
    await tester.pumpWidget(const LoversDictionaryApp());
  });
}