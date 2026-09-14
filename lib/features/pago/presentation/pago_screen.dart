import 'package:flutter/material.dart';

/// Placeholder del cobro. El WebView (camino A/B) se documenta en
/// `docs/integracion/FLUTTER.md`. No cargar claves Tilopay aquí.
class PagoScreen extends StatelessWidget {
  const PagoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WebView pendiente',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text(
              'Siguiente: ORDS POST /pay/iniciar y abrir checkoutUrl '
              '(app 110 p.1) en webview_flutter. '
              'La tarjeta no pasa por Dart.',
            ),
          ],
        ),
      ),
    );
  }
}
