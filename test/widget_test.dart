import 'package:flutter_test/flutter_test.dart';

import 'package:tilopay/main.dart';

void main() {
  testWidgets('Splash muestra Tilopay y pasa a Home', (WidgetTester tester) async {
    await tester.pumpWidget(const TilopayApp());
    expect(find.text('Tilopay'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('Checkout Tilopay'), findsOneWidget);
  });
}
