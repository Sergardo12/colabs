import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_sizes.dart';
import '../data/support_repository.dart';

class SuggestionServicePage extends StatefulWidget {
  const SuggestionServicePage({super.key});

  @override
  State<SuggestionServicePage> createState() => _SuggestionServicePageState();
}

class _SuggestionServicePageState extends State<SuggestionServicePage> {
  final _descCtrl = TextEditingController();
  bool  _loading  = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Describe el servicio que buscas')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<SupportRepository>().createSuggestion(
        description: 'Servicio sugerido: ${_descCtrl.text.trim()}',
      );
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:         Text('¡Gracias por tu sugerencia! 🙏'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar. Intenta de nuevo')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servicio')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Qué servicio le gustaría encontrar?',
              style: TextStyle(
                fontSize:   18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            const Text(
              'Cuéntanos qué servicio buscas y no encontraste en Colabs.',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: AppSizes.paddingXL),
            TextField(
              controller: _descCtrl,
              maxLines:   5,
              decoration: const InputDecoration(
                hintText: 'Ej: Servicio de fotografía para eventos...',
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _onSubmit,
                child: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enviar sugerencia'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}