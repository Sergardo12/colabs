import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../bloc/become_colab_bloc.dart';
import '../bloc/become_colab_event.dart';
import '../bloc/become_colab_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
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
        SnackBar(
          content: const Text('Selecciona al menos una ocupación'),
          backgroundColor: context.colors.error,
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
          context.read<ProfileBloc>().add(const ProfileLoadRequested());
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Ahora eres colaborador! 🎉'),
              backgroundColor: context.colors.primary,
            ),
          );
        }
        if (state is BecomeColabError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:         Text(state.message),
              backgroundColor: context.colors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.surface,
          elevation:       0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Convertirse en colaborador',
            style: TextStyle(
              color:      context.colors.textPrimary,
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
                      color:        context.colors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.handshake_outlined,
                          color: context.colors.primary,
                          size:  32,
                        ),
                        const SizedBox(width: AppSizes.paddingM),
                        Expanded(
                          child: Text(
                            'Comparte tus habilidades y empieza a recibir solicitudes de servicio',
                            style: TextStyle(
                              color:    context.colors.textPrimary,
                              fontSize: AppSizes.fontM,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXL),

                  // Ocupaciones
                  Text(
                    'Ocupaciones',
                    style: TextStyle(
                      color:      context.colors.textPrimary,
                      fontSize:   AppSizes.fontL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  Text(
                    'Selecciona al menos una',
                    style: TextStyle(
                      color:    context.colors.textSecondary,
                      fontSize: AppSizes.fontS,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingM),

                  BlocBuilder<BecomeColabBloc, BecomeColabState>(
                    builder: (context, state) {
                      if (state is OccupationsLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: context.colors.primary,
                          ),
                        );
                      }

                      if (state is OccupationsError) {
                        return Text(
                          state.message,
                          style: TextStyle(color: context.colors.error),
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
                  Text(
                    'Cuéntanos sobre ti',
                    style: TextStyle(
                      color:      context.colors.textPrimary,
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
                    decoration: InputDecoration(
                      hintText:   'Años de experiencia (ej. 5 años)',
                      prefixIcon: Icon(
                        Icons.work_outline,
                        color: context.colors.textSecondary,
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
                    decoration: InputDecoration(
                      hintText:   'Número de DNI',
                      prefixIcon: Icon(
                        Icons.badge_outlined,
                        color: context.colors.textSecondary,
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
                    decoration: InputDecoration(
                      hintText:   'Certificaciones (opcional)',
                      prefixIcon: Icon(
                        Icons.school_outlined,
                        color: context.colors.textSecondary,
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
                                  color:      Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Convertirme en colaborador',
                                style: TextStyle(
                                  color:      context.colors.white,
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
              ? context.colors.primary
              : context.colors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.textSecondary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check,
                color: Colors.white,
                size:  16,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              occupation.name,
              style: TextStyle(
                color: isSelected
                    ? context.colors.white
                    : context.colors.textPrimary,
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
