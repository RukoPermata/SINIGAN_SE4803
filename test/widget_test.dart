import 'package:flutter_test/flutter_test.dart';
import 'package:sini_gan/app.dart';

void main() {
  testWidgets('App smoke test - mounts SiniGanApp successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SiniGanApp());
    expect(find.byType(SiniGanApp), findsOneWidget);
  });
}
