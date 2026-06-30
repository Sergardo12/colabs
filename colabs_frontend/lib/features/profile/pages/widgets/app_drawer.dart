import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/app_router.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_state.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import '../../bloc/profile_state.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is ProfileError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.error),
                ),
              );
            }

            if (state is ProfileSuccess) {
              return Column(
                children: [
                  // Header del drawer
                  Container(
                    width:   double.infinity,
                    padding: const EdgeInsets.all(AppSizes.paddingXL),
                    color:   AppColors.primary,
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius:          40,
                          backgroundColor: AppColors.white.withOpacity(0.2),
                          backgroundImage: state.user.imageProfile != null
                              ? NetworkImage(state.user.imageProfile!)
                              : null,
                          child: state.user.imageProfile == null
                              ? const Icon(
                                  Icons.person,
                                  color: AppColors.white,
                                  size:  40,
                                )
                              : null,
                        ),
                        const SizedBox(height: AppSizes.paddingM),

                        // Nombre
                        Text(
                          '${state.user.name} ${state.user.lastName}',
                          style: const TextStyle(
                            color:      AppColors.white,
                            fontSize:   AppSizes.fontXL,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingXS),

                        // Email
                        Text(
                          state.user.email,
                          style: TextStyle(
                            color:    AppColors.white.withOpacity(0.8),
                            fontSize: AppSizes.fontM,
                          ),
                        ),

                        // Badge colaborador
                        if (state.colab != null) ...[
                          const SizedBox(height: AppSizes.paddingS),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingM,
                              vertical:   AppSizes.paddingXS,
                            ),
                            decoration: BoxDecoration(
                              color:        AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                            ),
                            child: Text(
                              state.colab!.occupations.isNotEmpty
                                  ? state.colab!.occupations.first.name
                                  : 'Colaborador',
                              style: const TextStyle(
                                color:    AppColors.white,
                                fontSize: AppSizes.fontS,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.paddingM),

                  // Ver mi perfil
                  ListTile(
                    leading: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                    ),
                    title: const Text(
                      'Ver mi perfil',
                      style: TextStyle(
                        color:    AppColors.textPrimary,
                        fontSize: AppSizes.fontL,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRouter.profile);
                    },
                  ),

                  // Convertirse en colaborador (si no es colaborador)
                  if (state.colab == null)
                    ListTile(
                      leading: const Icon(
                        Icons.handshake_outlined,
                        color: AppColors.primary,
                      ),
                      title: const Text(
                        'Convertirse en colaborador',
                        style: TextStyle(
                          color:    AppColors.textPrimary,
                          fontSize: AppSizes.fontL,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRouter.becomeColab);
                      },
                    ),

                  const Spacer(),

                  // Cerrar sesión
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    child: ElevatedButton(
                      onPressed: () async {
                        await context
                            .read<AuthBloc>()
                            .authRepository
                            .deleteToken();
                        Navigator.pushReplacementNamed(
                          context,
                          AppRouter.welcome,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      child: const Text(
                        'Cerrar sesión',
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}