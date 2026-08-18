import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/bloc/theme/theme_bloc.dart';
import '../../../../core/bloc/theme/theme_event.dart';
import '../../../../core/bloc/theme/theme_state.dart';
import '../../../auth/bloc/auth_bloc.dart';
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
      backgroundColor: context.colors.surface,
      child: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
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
              return Column(
                children: [
                  // Header del drawer
                  Container(
                    width:   double.infinity,
                    padding: const EdgeInsets.all(AppSizes.paddingXL),
                    color:   context.colors.primary,
                    child: Column(
                      children: [
                        // Avatar — navega al perfil público si es colaborador
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              final colab = state.colab;
                              if (colab == null) return;
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                AppRouter.publicProfile,
                                arguments: state.user.id,
                              );
                            },
                            child: CircleAvatar(
                              radius:          40,
                              backgroundColor: context.colors.white.withOpacity(0.2),
                              backgroundImage: state.user.imageProfile != null
                                  ? NetworkImage(state.user.imageProfile!)
                                  : null,
                              child: state.user.imageProfile == null
                                  ? Icon(
                                      Icons.person,
                                      color: context.colors.white,
                                      size:  40,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingM),

                        // Nombre
                        Text(
                          '${state.user.name} ${state.user.lastName}',
                          style: TextStyle(
                            color:      context.colors.white,
                            fontSize:   AppSizes.fontXL,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingXS),

                        // Email
                        Text(
                          state.user.email,
                          style: TextStyle(
                            color:    context.colors.white.withOpacity(0.8),
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
                              color:        context.colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                            ),
                            child: Text(
                              state.colab!.occupations.isNotEmpty
                                ? state.colab!.occupations
                                    .map((o) => o.name)
                                    .join(' · ')
                                : 'Colaborador',
                              style: TextStyle(
                                color:    context.colors.white,
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
                    leading: Icon(
                      Icons.person_outline,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    title: Text(
                      'Ver mi perfil',
                      style: TextStyle(
                        color:    context.colors.textPrimary,
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
                      leading: Icon(
                        Icons.handshake_outlined,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      title: Text(
                        'Convertirse en colaborador',
                        style: TextStyle(
                          color:    context.colors.textPrimary,
                          fontSize: AppSizes.fontL,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRouter.becomeColab);
                      },
                    ),

                  const Spacer(),

                  // Cambiar tema
                  BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, state) {
                      return ListTile(
                        leading: Icon(
                          state.isDark
                              ? Icons.bedtime_outlined
                              : Icons.wb_sunny_outlined,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        title: Text(
                          'Cambiar tema',
                          style: TextStyle(
                            color:    context.colors.textPrimary,
                            fontSize: AppSizes.fontL,
                          ),
                        ),
                        trailing: Switch(
                          value: state.isDark,
                          onChanged: (_) =>
                              context.read<ThemeBloc>().add(const ToggleTheme()),
                        ),
                      );
                    },
                  ),

                  // Cerrar sesión
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    child: ElevatedButton(
                      onPressed: () async {
                        await context
                            .read<AuthBloc>()
                            .authRepository
                            .deleteToken();
                        if (context.mounted) {
                          context
                              .read<ProfileBloc>()
                              .add(const ProfileLoadRequested());
                          Navigator.pushReplacementNamed(
                            context,
                            AppRouter.welcome,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.error,
                      ),
                      child: Text(
                        'Cerrar sesión',
                        style: TextStyle(color: context.colors.white),
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