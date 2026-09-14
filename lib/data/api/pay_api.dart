import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import 'pay_models.dart';

/// Cliente ORDS `/pay/`. Sin claves Tilopay. Sin PAN.
class PayApi {
  PayApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _root => AppConfig.apiBaseUrl.replaceAll(RegExp(r'/$'), '');

  bool get hostConfigured =>
      _root.isNotEmpty && !_root.contains('TU_HOST');

  Future<PayInicio> iniciar({
    required num monto,
    String moneda = 'CRC',
    required String email,
    required String nombre,
    required String apellido,
  }) async {
    if (!hostConfigured) {
      return const PayInicio(
        error: 'Falta el host ORDS en app_secrets.dart (apiBaseUrl).',
      );
    }

    final uri = Uri.parse('$_root/iniciar');
    final res = await _client
        .post(
          uri,
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'monto': monto,
            'moneda': moneda,
            'email': email,
            'nombre': nombre,
            'apellido': apellido,
          }),
        )
        .timeout(AppConfig.receiveTimeout);

    return _parseInicio(res);
  }

  /// Replica el GET de Tilopay para que `procesar_callback` corra en el servidor.
  Future<PayOrden> retorno(String callbackUrl) async {
    if (!hostConfigured) {
      return const PayOrden(error: 'Falta el host ORDS en app_secrets.dart.');
    }
    String? qp(Map<String, String> m, String key) {
      final want = key.toLowerCase();
      for (final e in m.entries) {
        if (e.key.toLowerCase() == want) return e.value;
      }
      return null;
    }

    final src = Uri.tryParse(callbackUrl);
    final q = src?.queryParameters ?? const <String, String>{};
    final body = {
      'order': qp(q, 'order'),
      'code': qp(q, 'code'),
      'auth': qp(q, 'auth'),
      'OrderHash': qp(q, 'OrderHash'),
      'tpt': qp(q, 'tpt') ?? qp(q, 'tilopay-transaction'),
      'description': qp(q, 'description'),
      'crd': qp(q, 'crd'),
    };

    PayOrden parsed(http.Response res) {
      try {
        final json = jsonDecode(res.body);
        if (json is Map<String, dynamic>) {
          final o = PayOrden.fromJson(json);
          if (res.statusCode >= 400 && o.error == null) {
            return PayOrden(error: 'HTTP ${res.statusCode}');
          }
          return o;
        }
      } catch (_) {}
      final snip =
          res.body.length > 180 ? res.body.substring(0, 180) : res.body;
      return PayOrden(error: 'HTTP ${res.statusCode} $snip');
    }

    var res = await _client
        .post(
          Uri.parse('$_root/retorno'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(AppConfig.receiveTimeout);

    if (res.statusCode == 404 || res.statusCode == 405) {
      res = await _client
          .get(
            Uri.parse('$_root/retorno').replace(queryParameters: {
              for (final e in body.entries)
                if (e.value != null && e.value!.isNotEmpty) e.key: e.value!,
            }),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(AppConfig.receiveTimeout);
    }
    return parsed(res);
  }

  Future<PayOrden> orden(String orderNumber) async {
    if (!hostConfigured) {
      return const PayOrden(
        error: 'Falta el host ORDS en app_secrets.dart (apiBaseUrl).',
      );
    }

    final uri = Uri.parse('$_root/orden/$orderNumber');
    final res = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(AppConfig.receiveTimeout);

    if (res.statusCode == 404) {
      return PayOrden(orderNumber: orderNumber, error: 'not_found');
    }
    final json = jsonDecode(res.body);
    if (json is! Map<String, dynamic>) {
      return const PayOrden(error: 'Respuesta ORDS inválida');
    }
    return PayOrden.fromJson(json);
  }

  PayInicio _parseInicio(http.Response res) {
    try {
      final json = jsonDecode(res.body);
      if (json is! Map<String, dynamic>) {
        return const PayInicio(error: 'Respuesta ORDS inválida');
      }
      final parsed = PayInicio.fromJson(json);
      if (res.statusCode >= 400 && parsed.error == null) {
        return PayInicio(error: 'HTTP ${res.statusCode}');
      }
      return parsed;
    } catch (e) {
      final snippet = res.body.length > 240 ? res.body.substring(0, 240) : res.body;
      return PayInicio(
        error: 'HTTP ${res.statusCode}: $e ${snippet.isEmpty ? '' : snippet}',
      );
    }
  }
}
