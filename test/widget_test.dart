import 'package:flutter_test/flutter_test.dart';
import 'package:emerkit/app.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const EmerKitApp());
    await tester.pumpAndSettle();
    expect(find.text('EmerKit'), findsOneWidget);
  });
}
