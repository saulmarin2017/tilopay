import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tilopay/main.dart';

void main() {
  testWidgets('Splash muestra Tilopay Demo y pasa a Login', (WidgetTester tester) async {
    await tester.pumpWidget(const TilopayApp());
    expect(find.text('Tilopay Demo'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('Usuario'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
  });

  testWidgets('Ingresar con usuario y clave abre Home', (WidgetTester tester) async {
    await tester.pumpWidget(const TilopayApp());
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'saul.marin');
    await tester.enterText(find.byType(TextField).at(1), '1234');
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();

    expect(find.text('Checkout Tilopay'), findsOneWidget);
  });

  testWidgets('Clave incorrecta no abre Home', (WidgetTester tester) async {
    await tester.pumpWidget(const TilopayApp());
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'saul.marin');
    await tester.enterText(find.byType(TextField).at(1), '0000');
    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(find.text('Usuario o contraseña incorrectos.'), findsOneWidget);
    expect(find.text('Checkout Tilopay'), findsNothing);
  });
}
