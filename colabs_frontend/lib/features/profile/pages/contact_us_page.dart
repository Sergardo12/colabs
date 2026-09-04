import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_sizes.dart';
import '../data/support_repository.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
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
        const SnackBar(content: Text('Ingresa el motivo')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<SupportRepository>().createSupport(
        description: _descCtrl.text.trim(),
      );
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:         Text('Mensaje enviado. Te contactaremos pronto 📩'),
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
      appBar: AppBar(title: const Text('Contáctanos directamente')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa el motivo',
              style: TextStyle(
                fontSize:   18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),
            TextField(
              controller: _descCtrl,
              maxLines:   6,
              decoration: const InputDecoration(
                hintText: 'Cuéntanos en qué podemos ayudarte...',
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
                    : const Text('Enviar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}