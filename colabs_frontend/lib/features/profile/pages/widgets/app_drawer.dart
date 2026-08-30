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
import '../../../notifications/bloc/notification_bloc.dart';
import '../../../notifications/bloc/notification_event.dart';
import '../../../notifications/bloc/notification_state.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _showAllOccupations = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
    context.read<NotificationBloc>().add(const NotificationsLoadRequested());
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
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    color:   context.colors.primary,
                    child: Row(
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
                              radius:          25,
                              backgroundColor: context.colors.white.withOpacity(0.2),
                              backgroundImage: state.user.imageProfile != null
                                  ? NetworkImage(state.user.imageProfile!)
                                  : null,
                              child: state.user.imageProfile == null
                                  ? Icon(
                                      Icons.person,
                                      color: context.colors.white,
                                      size:  28,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingM),

                        // Nombre + Badge colaborador
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize:       MainAxisSize.min,
                            children: [
                              // Nombre
                              Text(
                                '${state.user.name} ${state.user.lastName}',
                                style: TextStyle(
                                  color:      context.colors.white,
                                  fontSize:   AppSizes.fontL,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (state.colab != null) ...[
                                const SizedBox(height: AppSizes.paddingXS),
                                GestureDetector(
                                  onTap: () => setState(
                                    () => _showAllOccupations = !_showAllOccupations,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.paddingM,
                                      vertical:   AppSizes.paddingXS,
                                    ),
                                    decoration: BoxDecoration(
                                      color:        context.colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                                    ),
                                    child: _showAllOccupations
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize:       MainAxisSize.min,
                                            children: state.colab!.occupations.isNotEmpty
                                              ? state.colab!.occupations
                                                  .map((o) => Text(
                                                        o.name,
                                                        style: TextStyle(
                                                          color:    context.colors.white,
                                                          fontSize: AppSizes.fontS,
                                                        ),
                                                      ))
                                                  .toList()
                                              : [
                                                  Text(
                                                    'Colaborador',
                                                    style: TextStyle(
                                                      color:    context.colors.white,
                                                      fontSize: AppSizes.fontS,
                                                    ),
                                                  ),
                                                ],
                                          )
                                        : Text(
                                            state.colab!.occupations.isNotEmpty
                                              ? state.colab!.occupations
                                                  .map((o) => o.name)
                                                  .join(' · ')
                                              : 'Colaborador',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color:    context.colors.white,
                                              fontSize: AppSizes.fontS,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingS),

                        // Campana — notificaciones no leídas
                        BlocBuilder<NotificationBloc, NotificationState>(
                          builder: (context, nState) {
                            final unread = nState is NotificationLoaded
                                ? nState.unreadCount
                                : 0;
                            return Badge.count(
                              count:           unread,
                              isLabelVisible:  unread > 0,
                              backgroundColor: context.colors.error,
                              textColor:       context.colors.white,
                              offset:          const Offset(-8, 4),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.notifications,
                                  );
                                },
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: context.colors.white,
                                ),
                              ),
                            );
                          },
                        ),
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

                  // Favoritos — solo colaboradores
                  if (state.colab != null)
                    ListTile(
                      leading: Icon(
                        Icons.favorite_outline,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      title: Text(
                        'Favoritos',
                        style: TextStyle(
                          color:    context.colors.textPrimary,
                          fontSize: AppSizes.fontL,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRouter.favorites);
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