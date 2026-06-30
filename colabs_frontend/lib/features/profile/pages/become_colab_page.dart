import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../bloc/become_colab_bloc.dart';
import '../bloc/become_colab_event.dart';
import '../bloc/become_colab_state.dart';
import '../models/occupation_model.dart';

class BecomeColabPage extends StatefulWidget {
  const BecomeColabPage({super.key});

  @override
  State<BecomeColabPage> createState() => _BecomeColabPageState();
}

class _BecomeColabPageState extends State<BecomeColabPage> {
  final _formKey            = GlobalKey<FormState>();
  final _descriptionCtrl    = TextEditingController();
  final _experienceCtrl     = TextEditingController();
  final _dniCtrl            = TextEditingController();
  final _certificationsCtrl = TextEditingController();

  final List<String> _selectedOccupationIds = [];

  @override
  void initState() {
    super.initState();
    context.read<BecomeColabBloc>().add(const OccupationsLoadRequested());
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _experienceCtrl.dispose();
    _dniCtrl.dispose();
    _certificationsCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_selectedOccupationIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una ocupación'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.read<BecomeColabBloc>().add(
        BecomeColabSubmitted(
          description:    _descriptionCtrl.text.trim(),
          experience:     _experienceCtrl.text.trim(),
          dni:            _dniCtrl.text.trim(),
          occupationIds:  _selectedOccupationIds,
          certifications: _certificationsCtrl.text.trim().isEmpty
              ? null
              : _certificationsCtrl.text.trim(),
        ),
      );
    }
  }

  void _toggleOccupation(String id) {
    setState(() {
      if (_selectedOccupationIds.contains(id)) {
        _selectedOccupationIds.remove(id);
      } else {
        _selectedOccupationIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BecomeColabBloc, BecomeColabState>(
      listener: (context, state) {
        if (state is BecomeColabSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Ahora eres colaborador! 🎉'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
        if (state is BecomeColabError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:         Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation:       0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Convertirse en colaborador',
            style: TextStyle(
              color:      AppColors.textPrimary,
              fontSize:   AppSizes.fontL,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Header explicativo
                  Container(
                    width:   double.infinity,
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    decoration: BoxDecoration(
                      color:        AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.handshake_outlined,
                          color: AppColors.primary,
                          size:  32,
                        ),
                        SizedBox(width: AppSizes.paddingM),
                        Expanded(
                          child: Text(
                            'Comparte tus habilidades y empieza a recibir solicitudes de servicio',
                            style: TextStyle(
                              color:    AppColors.textPrimary,
                              fontSize: AppSizes.fontM,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXL),

                  // Ocupaciones
                  const Text(
                    'Ocupaciones',
                    style: TextStyle(
                      color:      AppColors.textPrimary,
                      fontSize:   AppSizes.fontL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  const Text(
                    'Selecciona al menos una',
                    style: TextStyle(
                      color:    AppColors.textSecondary,
                      fontSize: AppSizes.fontS,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  BlocBuilder<BecomeColabBloc, BecomeColabState>(
                    builder: (context, state) {
                      if (state is OccupationsLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      if (state is OccupationsError) {
                        return Text(
                          state.message,
                          style: const TextStyle(color: AppColors.error),
                        );
                      }

                      if (state is OccupationsLoaded) {
                        return Wrap(
                          spacing:   AppSizes.paddingS,
                          runSpacing: AppSizes.paddingS,
                          children: state.occupations.map((occupation) {
                            final isSelected = _selectedOccupationIds
                                .contains(occupation.id);
                            return _OccupationChip(
                              occupation: occupation,
                              isSelected: isSelected,
                              onTap: () => _toggleOccupation(occupation.id),
                            );
                          }).toList(),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingXL),

                  // Descripción
                  const Text(
                    'Cuéntanos sobre ti',
                    style: TextStyle(
                      color:      AppColors.textPrimary,
                      fontSize:   AppSizes.fontL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  TextFormField(
                    controller: _descriptionCtrl,
                    maxLines:   4,
                    decoration: const InputDecoration(
                      hintText: 'Describe tu experiencia y especialidad...',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Cuéntanos sobre ti';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Experiencia
                  TextFormField(
                    controller: _experienceCtrl,
                    decoration: const InputDecoration(
                      hintText:   'Años de experiencia (ej. 5 años)',
                      prefixIcon: Icon(
                        Icons.work_outline,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu experiencia';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // DNI
                  TextFormField(
                    controller:   _dniCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText:   'Número de DNI',
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu DNI';
                      }
                      if (value.length != 8) {
                        return 'DNI debe tener 8 dígitos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  // Certificaciones (opcional)
                  TextFormField(
                    controller: _certificationsCtrl,
                    decoration: const InputDecoration(
                      hintText:   'Certificaciones (opcional)',
                      prefixIcon: Icon(
                        Icons.school_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXL),

                  // Botón enviar
                  BlocBuilder<BecomeColabBloc, BecomeColabState>(
                    builder: (context, state) {
                      final isLoading = state is BecomeColabSubmitting;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _onSubmit,
                        child: isLoading
                            ? const SizedBox(
                                width:  20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color:      AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Convertirme en colaborador',
                                style: TextStyle(
                                  color:      AppColors.white,
                                  fontSize:   AppSizes.fontL,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingXL),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OccupationChip extends StatelessWidget {
  final OccupationItem occupation;
  final bool           isSelected;
  final VoidCallback   onTap;

  const _OccupationChip({
    required this.occupation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical:   AppSizes.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check,
                color: AppColors.white,
                size:  16,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              occupation.name,
              style: TextStyle(
                color: isSelected
                    ? AppColors.white
                    : AppColors.textPrimary,
                fontSize:   AppSizes.fontM,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}