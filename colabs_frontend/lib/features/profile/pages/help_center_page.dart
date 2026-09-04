import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_router.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Necesitas ayuda?'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Cuál es el motivo?',
              style: TextStyle(
                fontSize:   18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Opción 1 — Servicio solicitado
            _HelpOption(
              icon:        Icons.assignment_outlined,
              title:       'Servicio solicitado',
              description: 'No envía mis solicitudes, no cambia de estado mis solicitudes, etc.',
              onTap: () => Navigator.pushNamed(
                context, AppRouter.supportRequest),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Opción 2 — Reportar colaborador
            _HelpOption(
              icon:        Icons.flag_outlined,
              title:       'Reportar a un colaborador',
              description: 'Aceptó pero no llegó, actitud grosera, estafa, etc.',
              onTap: () => Navigator.pushNamed(
                context, AppRouter.reportColab),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Opción 3 — Servicio (sugerencia)
            _HelpOption(
              icon:        Icons.build_outlined,
              title:       'Servicio',
              description: 'No encontré el servicio que busco.',
              onTap: () => Navigator.pushNamed(
                context, AppRouter.suggestionService),
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // Contactanos directamente
            const Text(
              'Contáctanos directamente',
              style: TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context, AppRouter.contactUs),
                icon:  const Icon(Icons.headset_mic_outlined),
                label: const Text('Iniciar proceso'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpOption extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   description;
  final VoidCallback onTap;

  const _HelpOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width:  48,
              height: 48,
              decoration: BoxDecoration(
                color:        const Color(0xFF1E41BC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(icon, color: const Color(0xFF1E41BC), size: 24),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize:   15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color:    Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }
}