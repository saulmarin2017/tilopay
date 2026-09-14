import 'package:flutter_test/flutter_test.dart';
import 'package:tilopay/data/api/pay_models.dart';

void main() {
  test('PayInicio.ok exige order, token y sin error', () {
    expect(
      PayInicio.fromJson({
        'orderNumber': 'NS-1',
        'token': 'abc',
        'checkoutUrl': 'https://x/home',
        'error': null,
      }).ok,
      isTrue,
    );
    expect(
      PayInicio.fromJson({
        'orderNumber': null,
        'token': null,
        'error': 'boom',
      }).ok,
      isFalse,
    );
  });
}
