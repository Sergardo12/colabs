import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_router.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation:       0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mi perfil',
          style: TextStyle(
            color:      context.colors.textPrimary,
            fontSize:   AppSizes.fontXL,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.editColabProfile);
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            );
          }

          if (state is ProfileError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: context.colors.error),
              ),
            );
          }

          if (state is ProfileSuccess) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header con avatar y nombre
                  Container(
                    width:   double.infinity,
                    padding: const EdgeInsets.all(AppSizes.paddingXL),
                    color:   context.colors.surface,
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius:          50,
                          backgroundColor: context.colors.primary.withOpacity(0.1),
                          backgroundImage: state.user.imageProfile != null
                              ? NetworkImage(state.user.imageProfile!)
                              : null,
                          child: state.user.imageProfile == null
                              ? Icon(
                                  Icons.person,
                                  color: Theme.of(context).iconTheme.color,
                                  size:  50,
                                )
                              : null,
                        ),
                        const SizedBox(height: AppSizes.paddingM),

                        // Nombre
                        Text(
                          '${state.user.name} ${state.user.lastName}',
                          style: TextStyle(
                            color:      context.colors.textPrimary,
                            fontSize:   AppSizes.fontXXL,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Ocupación si es colaborador
                        if (state.colab != null &&
                            state.colab!.occupations.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.paddingXS),
                          Text(
                            state.colab!.occupations.first.name,
                            style: TextStyle(
                              color:    context.colors.primary,
                              fontSize: AppSizes.fontL,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingS),

                  // Info básica
                  _InfoSection(
                    title: 'Información básica',
                    items: [
                      _InfoItem(
                        icon:  Icons.email_outlined,
                        label: 'Email',
                        value: state.user.email,
                      ),
                      _InfoItem(
                        icon:  Icons.phone_outlined,
                        label: 'Teléfono',
                        value: state.user.phoneNumber,
                      ),
                      _InfoItem(
                        icon:  Icons.calendar_today_outlined,
                        label: 'Miembro desde',
                        value: _formatDate(state.user.registrationDate),
                      ),
                    ],
                  ),

                  // Info de colaborador
                  if (state.colab != null) ...[
                    const SizedBox(height: AppSizes.paddingS),
                    _InfoSection(
                      title: 'Perfil de colaborador',
                      items: [
                        _InfoItem(
                          icon:  Icons.description_outlined,
                          label: 'Descripción',
                          value: state.colab!.description,
                        ),
                        _InfoItem(
                          icon:  Icons.work_outline,
                          label: 'Experiencia',
                          value: state.colab!.experience,
                        ),
                        _InfoItem(
                          icon:  Icons.verified_outlined,
                          label: 'Verificación',
                          value: state.colab!.verificationStatus == 'verified'
                              ? 'Verificado ✅'
                              : 'Pendiente ⏳',
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppSizes.paddingXL),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _formatDate(String date) {
    final d = DateTime.parse(date);
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _InfoSection extends StatelessWidget {
  final String         title;
  final List<_InfoItem> items;

  const _InfoSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color:      context.colors.textPrimary,
              fontSize:   AppSizes.fontL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          ...items,
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).iconTheme.color, size: 20),
          const SizedBox(width: AppSizes.paddingM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color:    context.colors.textSecondary,
                  fontSize: AppSizes.fontS,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color:    context.colors.textPrimary,
                  fontSize: AppSizes.fontM,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
