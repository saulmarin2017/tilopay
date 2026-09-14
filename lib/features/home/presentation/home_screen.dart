import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/api/pay_api.dart';
import '../../../shared/widgets/labeled_field.dart';
import '../../pago/presentation/checkout_webview.dart';

/// Datos del cobro. La tarjeta (número, vence, CVV) solo va en el WebView SDK.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _montoCtrl = TextEditingController(text: '100');
  final _emailCtrl = TextEditingController(
    text: 'saul.marin@navasoftsoluciones.com',
  );
  final _nombreCtrl = TextEditingController(text: 'SAUL');
  final _apellidoCtrl = TextEditingController(text: 'MARIN');

  String? _msg;
  bool _busy = false;
  final _payApi = PayApi();

  @override
  void dispose() {
    _montoCtrl.dispose();
    _emailCtrl.dispose();
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pagar() async {
    setState(() {
      _msg = null;
      _busy = true;
    });
    final monto = num.tryParse(_montoCtrl.text.trim()) ?? 100;
    try {
      final inicio = await _payApi.iniciar(
        monto: monto,
        email: _emailCtrl.text.trim(),
        nombre: _nombreCtrl.text.trim(),
        apellido: _apellidoCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _busy = false);
      if (!inicio.ok) {
        setState(() => _msg = inicio.error ?? 'No se pudo iniciar el cobro.');
        return;
      }
      final checkout = inicio.checkoutUrl ?? '';
      final redirect = checkout.replaceFirst(RegExp(r'/home/?$'), '/callback');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CheckoutWebView(
            token: inicio.token!,
            orderNumber: inicio.orderNumber!,
            redirect: redirect,
            monto: _montoCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            nombre: _nombreCtrl.text.trim(),
            apellido: _apellidoCtrl.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _msg = 'ORDS: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(AppConfig.logoAsset, width: 32, height: 32),
            ),
            const SizedBox(width: 10),
            const Text('Tilopay'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _card(
            children: [
              LabeledField(
                label: 'Monto',
                child: TextField(
                  controller: _montoCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(height: 12),
              LabeledField(
                label: 'Email',
                child: TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(height: 12),
              LabeledField(
                label: 'Nombre',
                child: TextField(controller: _nombreCtrl),
              ),
              const SizedBox(height: 12),
              LabeledField(
                label: 'Apellido',
                child: TextField(controller: _apellidoCtrl),
              ),
              if (_msg != null) ...[
                const SizedBox(height: 12),
                Text(
                  _msg!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _busy ? null : _pagar,
                child: Text(_busy ? 'Iniciando…' : 'Pagar'),
              ),
              const SizedBox(height: 10),
              const Text(
                'La tarjeta se pide en la siguiente pantalla (Tilopay SDK).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE8EAED)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
