import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/api/pay_api.dart';
import '../../../shared/widgets/labeled_field.dart';
import '../../pago/presentation/checkout_webview.dart';

/// Checkout Flutter, mismo layout que APEX p.1 (app 110).
/// PAN no se envía por Dart: Pagar abre un resultado demo hasta el WebView.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _metodos = <String>[
    '',
    'Tarjeta de crédito o débito',
    'SINPE Móvil',
  ];

  final _montoCtrl = TextEditingController(text: '100');
  final _emailCtrl = TextEditingController(
    text: 'saul.marin@navasoftsoluciones.com',
  );
  final _nombreCtrl = TextEditingController(text: 'SAUL');
  final _apellidoCtrl = TextEditingController(text: 'MARIN');
  final _numeroCtrl = TextEditingController();
  final _venceCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  String _metodo = '';
  String _tarjetaGuardada = '';
  String? _msg;
  bool _busy = false;
  final _payApi = PayApi();

  bool get _esSinpe => _metodo == 'SINPE Móvil';

  @override
  void dispose() {
    _montoCtrl.dispose();
    _emailCtrl.dispose();
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _numeroCtrl.dispose();
    _venceCtrl.dispose();
    _cvvCtrl.dispose();
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
            ],
          ),
          const SizedBox(height: 12),
          _card(
            children: [
              Text(
                _msg ?? 'Listo para pagar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: _msg == null ? FontWeight.w400 : FontWeight.w600,
                  color: _msg == null ? AppColors.textSecondary : AppColors.error,
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 520;
                  final metodo = LabeledField(
                    label: 'Método de pago',
                    child: DropdownButtonFormField<String>(
                      initialValue: _metodo,
                      isExpanded: true,
                      items: _metodos
                          .map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: Text(
                                m.isEmpty ? 'Seleccione' : m,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() {
                        _metodo = v ?? '';
                        _msg = null;
                      }),
                    ),
                  );
                  final tarjetas = LabeledField(
                    label: 'Tarjetas guardadas',
                    child: DropdownButtonFormField<String>(
                      initialValue: _tarjetaGuardada,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: '',
                          child: Text(
                            'Nueva tarjeta',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _tarjetaGuardada = v ?? ''),
                    ),
                  );
                  if (_esSinpe) return metodo;
                  if (stacked) {
                    return Column(
                      children: [
                        metodo,
                        const SizedBox(height: 12),
                        tarjetas,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: metodo),
                      const SizedBox(width: 12),
                      Expanded(child: tarjetas),
                    ],
                  );
                },
              ),
              if (!_esSinpe) ...[
                const SizedBox(height: 12),
                LabeledField(
                  label: 'Número',
                  child: TextField(
                    controller: _numeroCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: '4111111111111111',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 14,
                      child: LabeledField(
                        label: 'Vence (MM/AA)',
                        child: TextField(
                          controller: _venceCtrl,
                          keyboardType: TextInputType.datetime,
                          decoration: const InputDecoration(hintText: '12/28'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 8,
                      child: LabeledField(
                        label: 'CVV',
                        child: TextField(
                          controller: _cvvCtrl,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _busy ? null : _pagar,
                child: Text(_busy ? 'Iniciando…' : 'Pagar'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Pago seguro · PCI via Tilopay SDK',
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
