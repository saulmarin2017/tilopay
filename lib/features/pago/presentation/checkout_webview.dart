import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../data/api/pay_api.dart';
import '../../../data/api/pay_models.dart';
import 'pago_screen.dart';

/// Camino B: HTML + sdk_tpay en WebView. PAN no pasa por Dart.
class CheckoutWebView extends StatefulWidget {
  const CheckoutWebView({
    super.key,
    required this.token,
    required this.orderNumber,
    required this.redirect,
    required this.monto,
    required this.email,
    required this.nombre,
    required this.apellido,
    this.moneda = 'CRC',
  });

  final String token;
  final String orderNumber;
  final String redirect;
  final String monto;
  final String email;
  final String nombre;
  final String apellido;
  final String moneda;

  @override
  State<CheckoutWebView> createState() => _CheckoutWebViewState();
}

class _CheckoutWebViewState extends State<CheckoutWebView> {
  WebViewController? _controller;
  var _closing = false;
  var _loading = true;
  var _closingUi = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    var html = await rootBundle.loadString('assets/tilopay/checkout.html');
    html = html
        .replaceAll('__TOKEN__', jsonEncode(widget.token))
        .replaceAll('__ORDER__', jsonEncode(widget.orderNumber))
        .replaceAll('__REDIRECT__', jsonEncode(widget.redirect))
        .replaceAll('__AMOUNT__', jsonEncode(widget.monto))
        .replaceAll('__CURRENCY__', jsonEncode(widget.moneda))
        .replaceAll('__EMAIL__', jsonEncode(widget.email))
        .replaceAll('__FIRST__', jsonEncode(widget.nombre))
        .replaceAll('__LAST__', jsonEncode(widget.apellido));

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF5F7FA))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _loading = true);
            _maybeCallback(url);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _loading = false);
            _maybeCallback(url);
          },
          onUrlChange: (change) {
            final url = change.url;
            if (url != null) _maybeCallback(url);
          },
          onNavigationRequest: (req) {
            _maybeCallback(req.url);
            return NavigationDecision.navigate;
          },
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final android = controller.platform as AndroidWebViewController;
      await android.setMediaPlaybackRequiresUserGesture(false);
    }

    await controller.loadHtmlString(html, baseUrl: 'https://app.tilopay.com/');
    if (!mounted) return;
    setState(() => _controller = controller);
  }

  bool _isCallback(String url) {
    final u = Uri.tryParse(url);
    if (u == null) return false;
    final path = u.path.toLowerCase();
    if (path.contains('callback')) return true;
    final code = u.queryParameters['code'];
    final order = u.queryParameters['order'];
    if (order != null &&
        order == widget.orderNumber &&
        code != null &&
        code.isNotEmpty) {
      return true;
    }
    return false;
  }

  void _maybeCallback(String url) {
    debugPrint('tilopay webview url=$url');
    if (_isCallback(url)) _onCallback(url);
  }

  Future<void> _onCallback(String url) async {
    if (_closing) return;
    _closing = true;
    if (mounted) setState(() => _closingUi = true);

    final u = Uri.tryParse(url);
    final order = u?.queryParameters['order'] ?? widget.orderNumber;
    final code = u?.queryParameters['code'];
    final auth = u?.queryParameters['auth'];
    final desc = u?.queryParameters['description'] ??
        u?.queryParameters['desc'];

    await Future<void>.delayed(const Duration(milliseconds: 700));

    PayOrden? remote;
    for (var i = 0; i < 5; i++) {
      try {
        remote = await PayApi().orden(order);
        final est = remote.estado ?? '';
        if (est == 'PENDIENTE_HASH' ||
            est == 'PAGADO' ||
            est == 'RECHAZADO' ||
            (remote.code != null && remote.code!.isNotEmpty)) {
          break;
        }
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }

    if (!mounted) return;

    final resolvedCode = remote?.code ?? code;
    final aprobado = resolvedCode == '1';
    var estado = remote?.estado ?? 'PENDIENTE';
    if (aprobado && estado == 'PENDIENTE') estado = 'PENDIENTE_HASH';

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PagoScreen(
          monto: widget.monto,
          email: widget.email,
          nombre: widget.nombre,
          apellido: widget.apellido,
          orderNumber: remote?.orderNumber ?? order,
          estado: estado,
          authCode: remote?.authCode ?? auth,
          code: resolvedCode,
          descripcion: desc ??
              (aprobado ? 'Transaction is approved' : remote?.error),
          marca: remote?.tilopayId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderNumber),
      ),
      body: c == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                WebViewWidget(controller: c),
                if (_loading) const LinearProgressIndicator(minHeight: 2),
                if (_closingUi)
                  const ColoredBox(
                    color: Color(0xCCFFFFFF),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Procesando resultado…'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
