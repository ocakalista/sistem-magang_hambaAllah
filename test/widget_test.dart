import 'package:flutter_test/flutter_test.dart';

import 'package:pemrog_hambaallah/main.dart';

void main() {
  testWidgets('renders Nexus app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const NexusApp());

    expect(find.text('Nexus'), findsOneWidget);
  });
}
