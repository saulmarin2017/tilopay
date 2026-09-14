import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../pago/presentation/pago_screen.dart';

/// Home del scaffold. El cobro (WebView) se arma en [PagoScreen].
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConfig.appName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Checkout Tilopay',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sandbox APEX (app 110) ya cobró. El WebView de esta app '
              'se conecta al mismo backend cuando exista ORDS /pay/.',
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PagoScreen()),
                );
              },
              icon: const Icon(Icons.credit_card),
              label: const Text('Ir a pago'),
            ),
          ],
        ),
      ),
    );
  }
}
