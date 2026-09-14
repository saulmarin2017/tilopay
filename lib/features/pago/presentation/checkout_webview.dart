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
/// El GET a `/callback` **sí** debe llegar a APEX (procesar_callback).
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
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _loading = false);
            if (_isCallback(url)) _onCallback(url);
          },
          onNavigationRequest: (req) {
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
    return u.path.toLowerCase().contains('/callback');
  }

  Future<void> _onCallback(String url) async {
    if (_closing) return;
    _closing = true;
    final u = Uri.tryParse(url);
    final order = u?.queryParameters['order'] ?? widget.orderNumber;
    final code = u?.queryParameters['code'];
    final auth = u?.queryParameters['auth'];
    PayOrden? remote;
    try {
      remote = await PayApi().orden(order);
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PagoScreen(
          monto: widget.monto,
          email: widget.email,
          nombre: widget.nombre,
          apellido: widget.apellido,
          orderNumber: remote?.orderNumber ?? order,
          estado: remote?.estado ??
              (code == '1' ? 'PENDIENTE_HASH' : 'PENDIENTE'),
          authCode: remote?.authCode ?? auth,
          code: remote?.code ?? code,
          descripcion: code == '1' ? 'Transaction is approved' : null,
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
              ],
            ),
    );
  }
}
