import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';

/// Recibo. Tras `POST /pay/iniciar` el estado es PENDIENTE (aún no cobró).
/// El WebView (paso 2) usará [checkoutUrl].
class PagoScreen extends StatelessWidget {
  const PagoScreen({
    super.key,
    this.monto = '100',
    this.email = '',
    this.nombre = '',
    this.apellido = '',
    this.orderNumber,
    this.checkoutUrl,
    this.token,
    this.estado = 'PENDIENTE',
    this.authCode,
    this.code,
    this.descripcion,
    this.marca,
    this.retornoError,
  });

  final String monto;
  final String email;
  final String nombre;
  final String apellido;
  final String? orderNumber;
  final String? checkoutUrl;
  final String? token;
  final String estado;
  final String? authCode;
  final String? code;
  final String? descripcion;
  final String? marca;
  final String? retornoError;

  bool get _aprobado =>
      estado == 'PAGADO' || estado == 'PENDIENTE_HASH' || code == '1';

  @override
  Widget build(BuildContext context) {
    final titulo = _aprobado ? 'Pago aprobado' : 'Orden creada';
    final sub = estado == 'PAGADO'
        ? 'Cobro confirmado. HMAC validado. Estado en BD: PAGADO.'
        : estado == 'PENDIENTE_HASH'
            ? 'Tilopay aprobó. El HMAC aún no coincidió (PENDIENTE_HASH).'
            : _aprobado
                ? 'Tilopay aprobó el cobro. Estado en BD: $estado.'
                : 'Todavía no hay code=1 de Tilopay.';

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
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          Material(
            color: Colors.white,
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFE8EAED)),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _aprobado
                          ? const [Color(0xFF146C38), AppColors.ok]
                          : const [Color(0xFFC43E00), AppColors.workOrange],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'TILOPAY DEMO',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        sub,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _row('Monto', '₡ $monto'),
                _row('Orden', orderNumber ?? '—'),
                if (!_aprobado && token != null && token!.isNotEmpty)
                  _tokenBlock(context),
                if (authCode != null) _row('Autorización', authCode!),
                if (code != null) _row('Código', code!),
                if (descripcion != null) _row('Descripción', descripcion!),
                if (marca != null) _row('Marca', marca!),
                if (nombre.isNotEmpty || apellido.isNotEmpty)
                  _row('Cliente', '$nombre $apellido'.trim()),
                if (email.isNotEmpty) _row('Email', email),
                _row('Estado', estado),
                if (retornoError != null && retornoError!.isNotEmpty)
                  _row('Retorno', retornoError!),
                if (checkoutUrl != null && checkoutUrl!.isNotEmpty)
                  _row('Checkout', checkoutUrl!),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Nuevo cobro'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tokenBlock(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F2F5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Token', style: TextStyle(color: AppColors.textSecondary)),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: token!));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Token copiado')),
                    );
                  }
                },
                child: const Text('Copiar'),
              ),
            ],
          ),
          SelectableText(
            token!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F2F5))),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
