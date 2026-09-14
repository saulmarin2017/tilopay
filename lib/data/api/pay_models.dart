/// Respuesta de `POST /pay/iniciar`.
class PayInicio {
  const PayInicio({
    this.orderNumber,
    this.token,
    this.checkoutUrl,
    this.error,
  });

  final String? orderNumber;
  final String? token;
  final String? checkoutUrl;
  final String? error;

  bool get ok =>
      error == null &&
      orderNumber != null &&
      orderNumber!.isNotEmpty &&
      token != null &&
      token!.isNotEmpty;

  factory PayInicio.fromJson(Map<String, dynamic> json) {
    return PayInicio(
      orderNumber: json['orderNumber'] as String?,
      token: json['token'] as String?,
      checkoutUrl: json['checkoutUrl'] as String?,
      error: json['error'] as String?,
    );
  }
}

/// Respuesta de `GET /pay/orden/:orderNumber`.
class PayOrden {
  const PayOrden({
    this.orderNumber,
    this.estado,
    this.monto,
    this.moneda,
    this.authCode,
    this.code,
    this.tilopayId,
    this.error,
  });

  final String? orderNumber;
  final String? estado;
  final num? monto;
  final String? moneda;
  final String? authCode;
  final String? code;
  final String? tilopayId;
  final String? error;

  factory PayOrden.fromJson(Map<String, dynamic> json) {
    return PayOrden(
      orderNumber: json['orderNumber'] as String?,
      estado: json['estado'] as String?,
      monto: json['monto'] as num?,
      moneda: json['moneda'] as String?,
      authCode: json['authCode'] as String?,
      code: json['code'] as String?,
      tilopayId: json['tilopayId'] as String?,
      error: json['error'] as String?,
    );
  }
}
