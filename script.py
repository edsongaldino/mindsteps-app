import sys

with open(r'c:\Projects\mindsteps-app\lib\features\psicologo\paciente_detalhe_page.dart', 'r', encoding='utf-8') as f:
    content = f.read()

start_str = 'void _verDetalhesCheckin(BuildContext context, Map<String, dynamic> checkin) {'
end_str = 'void _verDetalhesRegistro(BuildContext context, Map<String, dynamic> registro) {'

start_idx = content.find(start_str)
end_idx = content.find(end_str)

if start_idx != -1 and end_idx != -1:
    new_func = r'''void _verDetalhesCheckin(BuildContext context, Map<String, dynamic> checkin) {
  final emocao = checkin['emocaoPrincipal'] ?? 'Não informada';
  final obs = checkin['observacao'];
  final criadoEmStr = checkin['criadoEm'];

  String dataCheckin = '';
  if (criadoEmStr != null) {
    try {
      final dt = DateTime.parse(criadoEmStr.toString()).toLocal();
      dataCheckin = '// às :';
    } catch (_) {}
  }

  IconData getIconeEmocao(String e) {
    switch (e) {
      case 'Amor': return LucideIcons.heart;
      case 'Alegria': return LucideIcons.smile;
      case 'Calma': return LucideIcons.smile;
      case 'Gratidão': return LucideIcons.smilePlus;
      case 'Tranquilidade': return LucideIcons.smile;
      case 'Raiva': return LucideIcons.angry;
      case 'Ansiedade': return LucideIcons.frown;
      case 'Tristeza': return LucideIcons.frown;
      case 'Estresse': return LucideIcons.zap;
      case 'Tédio': return LucideIcons.meh;
      case 'Irritação': return LucideIcons.flame;
      case 'Confusão': return LucideIcons.helpCircle;
      case 'Cansaço': return LucideIcons.moon;
      case 'Esperança': return LucideIcons.sun;
      case 'Motivação': return LucideIcons.rocket;
      case 'Outra': return LucideIcons.moreHorizontal;
      default: return LucideIcons.smile;
    }
  }

  Color getCorEmocao(String e) {
    switch (e) {
      case 'Amor': return Colors.pink;
      case 'Alegria': return Colors.orange;
      case 'Calma': return Colors.blue;
      case 'Gratidão': return Colors.green;
      case 'Tranquilidade': return Colors.purple;
      case 'Raiva': return Colors.red;
      case 'Ansiedade': return Colors.deepOrange;
      case 'Tristeza': return Colors.orange;
      case 'Estresse': return Colors.deepPurple;
      case 'Tédio': return Colors.teal;
      case 'Irritação': return Colors.redAccent;
      case 'Confusão': return Colors.grey;
      case 'Cansaço': return Colors.indigo;
      case 'Esperança': return Colors.green;
      case 'Motivação': return Colors.pinkAccent;
      case 'Outra': return Colors.blueGrey;
      default: return AppColors.primary;
    }
  }

  Color getCorFundoEmocao(String e) {
    switch (e) {
      case 'Amor': return const Color(0xFFFFE5E5);
      case 'Alegria': return const Color(0xFFFFF2E5);
      case 'Calma': return const Color(0xFFE5F0FF);
      case 'Gratidão': return const Color(0xFFE5FFE5);
      case 'Tranquilidade': return const Color(0xFFF3E5F5);
      case 'Raiva': return const Color(0xFFFFE5E5);
      case 'Ansiedade': return const Color(0xFFFFEBE5);
      case 'Tristeza': return const Color(0xFFFFF2E5);
      case 'Estresse': return const Color(0xFFEBE5FF);
      case 'Tédio': return const Color(0xFFE5FFFA);
      case 'Irritação': return const Color(0xFFFFE5E5);
      case 'Confusão': return const Color(0xFFF0F0F0);
      case 'Cansaço': return const Color(0xFFE5F0FF);
      case 'Esperança': return const Color(0xFFE5FFE5);
      case 'Motivação': return const Color(0xFFFFE5F2);
      case 'Outra': return const Color(0xFFF0F0F0);
      default: return const Color(0xFFF5F3FF);
    }
  }

  final iconEmocao = getIconeEmocao(emocao);
  final corEmocao = getCorEmocao(emocao);
  final corFundoEmocao = getCorFundoEmocao(emocao);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: AppColors.background,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Check-in Emocional',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dataCheckin,
                        style: const TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: corFundoEmocao,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconEmocao, color: corEmocao, size: 36),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Emoção principal',
                          style: TextStyle(color: AppColors.muted, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          emocao,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Relato / Observação',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.softGreen.withOpacity(0.5)),
              ),
              child: Text(
                (obs != null && obs.toString().trim().isNotEmpty) ? obs : 'Paciente não deixou observações adicionais para este check-in.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.text,
                  fontStyle: (obs != null && obs.toString().trim().isNotEmpty) ? FontStyle.normal : FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Fechar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

'''
    
    new_content = content[:start_idx] + new_func + content[end_idx:]
    with open(r'c:\Projects\mindsteps-app\lib\features\psicologo\paciente_detalhe_page.dart', 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Replaced successfully")
else:
    print("Start or end index not found!")
