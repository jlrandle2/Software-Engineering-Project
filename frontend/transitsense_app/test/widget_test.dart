import 'package:flutter_test/flutter_test.dart';
import 'package:transitsense_app/main.dart';

void main() {
  testWidgets('TransitSense app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const TransitSenseApp());
    expect(find.byType(TransitSenseApp), findsOneWidget);
  });
}