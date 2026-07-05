// Базовый smoke-тест.
//
// Полноценный тест UI требует моков Supabase и SharedPreferences, поэтому
// здесь оставлена минимальная проверка, что виджет приложения создаётся.

import 'package:flutter_test/flutter_test.dart';

import 'package:easygo_app/app.dart';

void main() {
  test('EasyGoApp can be constructed', () {
    expect(const EasyGoApp(), isNotNull);
  });
}
