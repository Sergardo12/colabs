import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_sizes.dart';
import '../../service_request/models/reportable_service_model.dart';
import '../bloc/report_colab_bloc.dart';
import '../bloc/report_colab_event.dart';
import '../bloc/report_colab_state.dart';

class ReportColabPage extends StatefulWidget {
  const ReportColabPage({super.key});

  @override
  State<ReportColabPage> createState() => _ReportColabPageState();
}

class _ReportColabPageState extends State<ReportColabPage> {
  final _descCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  String _reason = '';

  @override
  void initState() {
    super.initState();
    context.read<ReportColabBloc>().add(
          const ReportCancelledServicesLoadRequested(),
        );
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final state = context.read<ReportColabBloc>().state;
    if (state.selected == null || _reason.trim().isEmpty) return;

    context.read<ReportColabBloc>().add(
          ReportSubmitRequested(_reason),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportColabBloc, ReportColabState>(
      listenWhen: (previous, current) =>
          current.status == ReportColabStatus.submitted ||
          current.status == ReportColabStatus.alreadyReported ||
          current.status == ReportColabStatus.failure,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);

        if (state.status == ReportColabStatus.submitted) {
          Navigator.pop(context);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Reporte enviado. Lo revisaremos pronto 🔍'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
          return;
        }

        if (state.status == ReportColabStatus.alreadyReported) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Este servicio ya fue reportado')),
          );
          return;
        }

        messenger.showSnackBar(
          SnackBar(
            content: Text(
              state.errorMessage ?? 'Error al enviar. Intenta de nuevo',
            ),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Reportar a un colaborador')),
        body: BlocBuilder<ReportColabBloc, ReportColabState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (value) => context
                        .read<ReportColabBloc>()
                        .add(ReportSearchChanged(value)),
                    decoration: const InputDecoration(
                      hintText: 'Buscar servicio...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  const Text(
                    'Selecciona el servicio relacionado',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  _buildServices(context, state),
                  const SizedBox(height: AppSizes.paddingL),
                  const Text(
                    'Cuéntenos el motivo',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 5,
                    onChanged: (value) =>
                        setState(() => _reason = value),
                    decoration: const InputDecoration(
                      hintText: 'Describe lo que pasó...',
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingL),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (state.isSubmitting ||
                              state.selected == null ||
                              _reason.trim().isEmpty)
                          ? null
                          : _submit,
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Enviar reporte'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServices(
    BuildContext context,
    ReportColabState state,
  ) {
    if ((state.status == ReportColabStatus.initial ||
            state.isLoading) &&
        state.services.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingL),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.status == ReportColabStatus.failure &&
        state.services.isEmpty) {
      return Text(
        state.errorMessage ?? 'No se pudieron cargar los servicios',
        style: const TextStyle(color: Colors.red),
      );
    }

    if (state.services.isEmpty) {
      return const Text(
        'No tienes servicios cancelados con colaborador asignado.',
        style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
      );
    }

    return Column(
      children: state.services
          .map(
            (service) => _RequestTile(
              request: service,
              isSelected: state.selected?.id == service.id,
              onTap: () {
                final bloc = context.read<ReportColabBloc>();
                if (state.selected?.id == service.id) {
                  bloc.add(const ReportServiceSelected(null));
                } else {
                  bloc.add(ReportServiceSelected(service));
                }
              },
            ),
          )
          .toList(),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final ReportableServiceModel request;
  final bool isSelected;
  final VoidCallback onTap;

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
            : Color(0xFF1E41BC).withValues(alpha: 0.1),
        child: Icon(
          Icons.build_outlined,
          color: isSelected ? Colors.white : const Color(0xFF1E41BC),
          size: 18,
        ),
      ),
      title: Text(
        request.occupation.name,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
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
