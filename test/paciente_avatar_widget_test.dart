import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsteps_app/features/paciente/widgets/avatar_widget.dart';
import 'package:mindsteps_app/features/psicologo/widgets/paciente_avatar_widget.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('PacienteAvatarWidget Tests', () {
    testWidgets('Renderiza avatar 3D quando fotoUrl contém avatar:...', (WidgetTester tester) async {
      const avatarFoto =
          'avatar:{"tomPele":"#F5D0A9","formatoRosto":"oval","estiloCabelo":"curto","corCabelo":"#2C1B18","expressao":"alegre","estiloRoupa":"casual","corRoupa":"#4F46E5","acessorios":[]}';

      await tester.pumpWidget(
        buildTestableWidget(
          const PacienteAvatarWidget(
            fotoUrl: avatarFoto,
            nome: 'Édson Galdino',
            radius: 24,
          ),
        ),
      );

      expect(find.byType(AvatarWidget), findsOneWidget);
    });

    testWidgets('Renderiza fallback inicial quando fotoUrl é nula', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PacienteAvatarWidget(
            fotoUrl: null,
            nome: 'Ana Cecília',
            radius: 24,
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('Renderiza inicial acentuada corretamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PacienteAvatarWidget(
            fotoUrl: null,
            nome: 'Édson Galdino',
            radius: 24,
          ),
        ),
      );

      expect(find.text('É'), findsOneWidget);
    });

    testWidgets('Renderiza Image.network quando fotoUrl é uma URL http/https', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PacienteAvatarWidget(
            fotoUrl: 'https://exemplo.com/foto.jpg',
            nome: 'Carla',
            radius: 24,
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });
  });
}
