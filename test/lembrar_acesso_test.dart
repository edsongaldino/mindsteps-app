import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindsteps_app/core/auth/auth_storage.dart';
import 'package:mindsteps_app/features/auth/login_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Lembrar Acesso - AuthStorage & UI', () {
    test('Salva, obtém e limpa credenciais lembradas em AuthStorage', () async {
      SharedPreferences.setMockInitialValues({});

      // Inicialmente não há credenciais lembradas
      var creds = await AuthStorage.obterCredenciaisLembradas();
      expect(creds, isNull);

      // Salva
      await AuthStorage.salvarCredenciaisLembradas('psicologo@mindsteps.com', '123456');

      // Obtém
      creds = await AuthStorage.obterCredenciaisLembradas();
      expect(creds, isNotNull);
      expect(creds!['email'], equals('psicologo@mindsteps.com'));
      expect(creds['senha'], isNotNull);

      // Limpa credenciais
      await AuthStorage.limparCredenciaisLembradas();
      creds = await AuthStorage.obterCredenciaisLembradas();
      expect(creds, isNull);
    });

    testWidgets('LoginPage exibe checkbox Lembrar acesso e permite alternar', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verifica existência do texto e do Checkbox
      expect(find.text('Lembrar acesso'), findsOneWidget);
      expect(find.text('Esqueci minha senha'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);

      // Clica no checkbox
      await tester.tap(find.text('Lembrar acesso'));
      await tester.pumpAndSettle();

      Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isTrue);

      // Clica novamente para desmarcar
      await tester.tap(find.text('Lembrar acesso'));
      await tester.pumpAndSettle();

      checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });
  });
}
