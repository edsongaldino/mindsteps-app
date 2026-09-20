import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindsteps_app/features/psicologo/widgets/resposta_atividade_widget.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );
  }

  group('RespostaAtividadeWidget Tests', () {
    testWidgets('Renderiza Decisão Sob Pressão com sucesso', (WidgetTester tester) async {
      const jsonStr =
          '{"situacao":"Você enviou uma mensagem importante. A pessoa visualizou há 4 horas e não respondeu.","acao_escolhida":"Esperar com calma e responder normalmente depois","tipo_acao":"Assertiva","respirou":true}';

      await tester.pumpWidget(
        buildTestableWidget(
          const RespostaAtividadeWidget(
            resposta: jsonStr,
            tituloAtividade: 'Decisão Sob Pressão',
          ),
        ),
      );

      expect(find.text('Comportamento Assertivo'), findsOneWidget);
      expect(find.text('Pausa para Respiração Realizada'), findsOneWidget);
      expect(find.text('SITUAÇÃO APRESENTADA'), findsOneWidget);
      expect(
        find.text('Você enviou uma mensagem importante. A pessoa visualizou há 4 horas e não respondeu.'),
        findsOneWidget,
      );
      expect(find.text('AÇÃO ESCOLHIDA PELO PACIENTE'), findsOneWidget);
      expect(
        find.text('Esperar com calma e responder normalmente depois'),
        findsOneWidget,
      );
    });

    testWidgets('Renderiza Decisão Sob Pressão Impulsiva sem respiração', (WidgetTester tester) async {
      const jsonStr =
          '{"situacao":"Conflito no trabalho","acao_escolhida":"Responder na hora com agressividade","tipo_acao":"Impulsiva","respirou":false}';

      await tester.pumpWidget(
        buildTestableWidget(
          const RespostaAtividadeWidget(
            resposta: jsonStr,
            tituloAtividade: 'Decisão Sob Pressão',
          ),
        ),
      );

      expect(find.text('Comportamento Impulsivo'), findsOneWidget);
      expect(find.text('Sem Pausa Respiratória'), findsOneWidget);
      expect(find.text('Responder na hora com agressividade'), findsOneWidget);
    });

    testWidgets('Renderiza resposta em texto livre convencional', (WidgetTester tester) async {
      const texto = 'Consegui praticar a respiração e me senti muito mais calmo durante o dia.';

      await tester.pumpWidget(
        buildTestableWidget(
          const RespostaAtividadeWidget(
            resposta: texto,
            tituloAtividade: 'Diário de Bordo',
          ),
        ),
      );

      expect(find.text(texto), findsOneWidget);
    });

    testWidgets('Renderiza métricas de jogo de performance', (WidgetTester tester) async {
      const jsonStr =
          '{"jogo":"Missão Foco","total_rodadas":10,"acertos":9,"erros":1,"precisao":90}';

      await tester.pumpWidget(
        buildTestableWidget(
          const RespostaAtividadeWidget(
            resposta: jsonStr,
            tituloAtividade: 'Missão Foco',
          ),
        ),
      );

      expect(find.text('Missão Foco'), findsOneWidget);
      expect(find.text('Precisão'), findsOneWidget);
      expect(find.text('90%'), findsOneWidget);
      expect(find.text('Acertos'), findsOneWidget);
      expect(find.text('9/10'), findsOneWidget);
      expect(find.text('Erros'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Renderiza estado vazio quando resposta for nula ou vazia', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const RespostaAtividadeWidget(
            resposta: null,
            tituloAtividade: 'Atividade sem resposta',
          ),
        ),
      );

      expect(find.text('Nenhuma resposta registrada pelo paciente.'), findsOneWidget);
    });
  });
}
