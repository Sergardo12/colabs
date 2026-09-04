import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_sizes.dart';
import '../../service_request/bloc/service_request_bloc.dart';
import '../../service_request/bloc/service_request_state.dart';
import '../../service_request/bloc/service_request_event.dart';
import '../../service_request/models/service_request_model.dart';
import '../data/support_repository.dart';

class SupportRequestPage extends StatefulWidget {
  const SupportRequestPage({super.key});

  @override
  State<SupportRequestPage> createState() => _SupportRequestPageState();
}

class _SupportRequestPageState extends State<SupportRequestPage> {
  final _descCtrl               = TextEditingController();
  final _searchCtrl             = TextEditingController();
  String _searchQuery           = '';
  ServiceRequestModel? _selected;
  bool _loading                 = false;

  @override
  void initState() {
    super.initState();
    context.read<ServiceRequestBloc>().add(const MyRequestsLoadRequested());
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuéntanos el motivo')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final desc = _selected != null
          ? 'Solicitud: ${_selected!.occupation.name} — ${_descCtrl.text.trim()}'
          : _descCtrl.text.trim();
      await context.read<SupportRepository>().createSupport(
        description: desc,
      );
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:         Text('Ticket enviado. Te contactaremos pronto 📩'),
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
      appBar: AppBar(title: const Text('Servicio solicitado')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lista de servicios recientes
            BlocBuilder<ServiceRequestBloc, ServiceRequestState>(
              builder: (context, state) {
                if (state is! ServiceRequestSuccess) {
                  return const SizedBox.shrink();
                }
                final recent = state.requests
                    .where((r) =>
                        _searchQuery.isEmpty ||
                        r.occupation.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        r.description.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .take(_searchQuery.isEmpty ? 3 : 5)
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText:   'Buscar servicio...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    const Text(
                      'Servicios recientes',
                      style: TextStyle(
                        fontSize:   15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    ...recent.map((r) => _RequestTile(
                      request:    r,
                      isSelected: _selected?.id == r.id,
                      onTap: () => setState(() =>
                          _selected = _selected?.id == r.id ? null : r),
                    )),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSizes.paddingL),

            const Text(
              'Cuéntenos el motivo',
              style: TextStyle(
                fontSize:   15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            TextField(
              controller: _descCtrl,
              maxLines:   5,
              decoration: const InputDecoration(
                hintText: 'Describe tu problema...',
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

class _RequestTile extends StatelessWidget {
  final ServiceRequestModel request;
  final bool                isSelected;
  final VoidCallback        onTap;

  const _RequestTile({
    required this.request,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isSelected
            ? const Color(0xFF1E41BC)
            : const Color(0xFF1E41BC).withOpacity(0.1),
        child: Icon(
          Icons.build_outlined,
          color: isSelected ? Colors.white : const Color(0xFF1E41BC),
          size: 18,
        ),
      ),
      title: Text(
        request.occupation.name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        request.description,
        style: const TextStyle(fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF1E41BC))
          : null,
      onTap: onTap,
    );
  }
}