import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../bloc/edit_colab_profile_bloc.dart';
import '../bloc/edit_colab_profile_event.dart';
import '../bloc/edit_colab_profile_state.dart';
import '../models/occupation_model.dart';

class EditColabProfilePage extends StatefulWidget {
  const EditColabProfilePage({super.key});

  @override
  State<EditColabProfilePage> createState() => _EditColabProfilePageState();
}

class _EditColabProfilePageState extends State<EditColabProfilePage> {
  final _formKey         = GlobalKey<FormState>();
  final _nameCtrl        = TextEditingController();
  final _lastNameCtrl    = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _dateBirthCtrl   = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _experienceCtrl  = TextEditingController();
  final _certCtrl        = TextEditingController();

  String? _selectedGender;
  final List<String> _selectedOccupationIds = [];
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    context.read<EditColabProfileBloc>().add(const EditColabProfileLoadRequested());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _dateBirthCtrl.dispose();
    _descriptionCtrl.dispose();
    _experienceCtrl.dispose();
    _certCtrl.dispose();
    super.dispose();
  }

  void _initializeControllers(EditColabProfileLoaded state) {
    if (_controllersInitialized) return;
    _controllersInitialized = true;

    _nameCtrl.text        = state.user.name;
    _lastNameCtrl.text    = state.user.lastName;
    _phoneCtrl.text       = state.user.phoneNumber;
    _dateBirthCtrl.text   = state.user.dateBirth ?? '';
    _selectedGender       = state.user.gender;
    _descriptionCtrl.text = state.colab.description;
    _experienceCtrl.text  = state.colab.experience;

    _selectedOccupationIds
      ..clear()
      ..addAll(state.colab.occupations.map((o) => o.id));
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
      context.read<EditColabProfileBloc>().add(
        EditColabProfileSubmitted(
          name:           _nameCtrl.text.trim(),
          lastName:       _lastNameCtrl.text.trim(),
          phoneNumber:    _phoneCtrl.text.trim(),
          dateBirth:      _dateBirthCtrl.text.trim().isEmpty
              ? null
              : _dateBirthCtrl.text.trim(),
          gender:         _selectedGender,
          description:    _descriptionCtrl.text.trim(),
          experience:     _experienceCtrl.text.trim(),
          certifications: _certCtrl.text.trim().isEmpty
              ? null
              : _certCtrl.text.trim(),
          occupationIds:  _selectedOccupationIds,
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
    return BlocListener<EditColabProfileBloc, EditColabProfileState>(
      listener: (context, state) {
        if (state is EditColabProfileSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado correctamente'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
        if (state is EditColabProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
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
            'Editar perfil',
            style: TextStyle(
              color:      AppColors.textPrimary,
              fontSize:   AppSizes.fontXL,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<EditColabProfileBloc, EditColabProfileState>(
          builder: (context, state) {
            if (state is EditColabProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is EditColabProfileError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }

            if (state is EditColabProfileLoaded) {
              _initializeControllers(state);
              return _buildForm(state);
            }

            if (state is EditColabProfileSubmitting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildForm(EditColabProfileLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Información personal'),
            const SizedBox(height: AppSizes.paddingM),

            TextFormField(
              controller:   _nameCtrl,
              decoration: const InputDecoration(
                hintText:   'Nombre',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: AppSizes.paddingM),

            TextFormField(
              controller:   _lastNameCtrl,
              decoration: const InputDecoration(
                hintText:   'Apellido',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: AppSizes.paddingM),

            TextFormField(
              controller:   _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText:   'Teléfono',
                prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textSecondary),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                if (v.length < 9) return 'Teléfono inválido';
                return null;
              },
            ),
            const SizedBox(height: AppSizes.paddingM),

            TextFormField(
              controller:   _dateBirthCtrl,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                hintText:   'Fecha de nacimiento (YYYY-MM-DD)',
                prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                hintText:   'Género',
                prefixIcon: Icon(Icons.wc_outlined, color: AppColors.textSecondary),
              ),
              items: const [
                DropdownMenuItem(value: 'male',   child: Text('Masculino')),
                DropdownMenuItem(value: 'female', child: Text('Femenino')),
                DropdownMenuItem(value: 'other',  child: Text('Otro')),
              ],
              onChanged: (v) => setState(() => _selectedGender = v),
            ),

            const SizedBox(height: AppSizes.paddingL),
            _buildSectionTitle('Perfil de colaborador'),
            const SizedBox(height: AppSizes.paddingM),

            TextFormField(
              controller:   _descriptionCtrl,
              maxLines:     3,
              decoration: const InputDecoration(
                hintText:    'Descripción de tus servicios',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.description_outlined, color: AppColors.textSecondary),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                if (v.length < 10) return 'Mínimo 10 caracteres';
                return null;
              },
            ),
            const SizedBox(height: AppSizes.paddingM),

            TextFormField(
              controller:   _experienceCtrl,
              decoration: const InputDecoration(
                hintText:   'Años de experiencia',
                prefixIcon: Icon(Icons.work_outline, color: AppColors.textSecondary),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: AppSizes.paddingM),

            TextFormField(
              controller:   _certCtrl,
              decoration: const InputDecoration(
                hintText:   'Certificaciones (opcional)',
                prefixIcon: Icon(Icons.verified_outlined, color: AppColors.textSecondary),
              ),
            ),

            const SizedBox(height: AppSizes.paddingL),
            _buildSectionTitle('Ocupaciones'),
            const SizedBox(height: AppSizes.paddingS),

            Wrap(
              spacing:         AppSizes.paddingS,
              runSpacing:      AppSizes.paddingS,
              children: state.availableOccupations.map((occ) {
                final isSelected = _selectedOccupationIds.contains(occ.id);
                return _OccupationChip(
                  occupation: occ,
                  isSelected: isSelected,
                  onTap:      () => _toggleOccupation(occ.id),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSizes.paddingXL),

            SizedBox(
              width:  double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: state is EditColabProfileSubmitting
                    ? null
                    : _onSubmit,
                child: state is EditColabProfileSubmitting
                    ? const SizedBox(
                        height: 20,
                        width:  20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(
                          color:      AppColors.white,
                          fontSize:   AppSizes.fontL,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color:      AppColors.textPrimary,
        fontSize:   AppSizes.fontL,
        fontWeight: FontWeight.bold,
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
          color: isSelected ? AppColors.primary : AppColors.white,
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
              const Icon(Icons.check, color: AppColors.white, size: 16),
              const SizedBox(width: 4),
            ],
            Text(
              occupation.name,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
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
