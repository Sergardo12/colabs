import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../profile/data/profile_repository.dart';
import '../../../service_request/bloc/service_request_bloc.dart';
import '../../../service_request/bloc/service_request_event.dart';
import '../../../service_request/bloc/service_request_state.dart';
import '../../../service_request/models/service_request_model.dart';

class SpecialtyRequestsTab extends StatefulWidget {
  const SpecialtyRequestsTab({super.key});

  @override
  State<SpecialtyRequestsTab> createState() => _SpecialtyRequestsTabState();
}

class _SpecialtyRequestsTabState extends State<SpecialtyRequestsTab> {
  static const Duration _publishInterval = Duration(seconds: 45);

  Timer?                 _publishTimer;
  Position?              _lastPosition;
  bool                   _publishingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _activateAvailability());
  }

  @override
  void dispose() {
    _publishTimer?.cancel();
    _publishTimer = null;
    _deactivateAvailability();
    super.dispose();
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _activateAvailability() async {
    if (_publishingLocation) return;
    setState(() => _publishingLocation = true);

    final position = await _getCurrentPosition();
    if (!mounted) return;

    if (position == null) {
      setState(() => _publishingLocation = false);
      context
          .read<ServiceRequestBloc>()
          .add(const NearbyRequestsLocationUnavailable());
      return;
    }

    _lastPosition = position;
    await _republishLocation();

    if (!mounted) return;
    setState(() => _publishingLocation = false);
    context.read<ServiceRequestBloc>().add(const NearbyRequestsLoadRequested());
    _publishTimer?.cancel();
    _publishTimer = Timer.periodic(_publishInterval, (_) {
      _republishLocation();
    });
  }

  Future<void> _republishLocation() async {
    final position = _lastPosition;
    if (position == null) return;
    try {
      await context.read<ProfileRepository>().updateLocation(
        lat: position.latitude,
        lng: position.longitude,
      );
    } catch (_) {}
  }

  Future<void> _deactivateAvailability() async {
    try {
      if (mounted) {
        await context.read<ProfileRepository>().deactivateLocation();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: context.colors.surface,
        elevation:       0,
        title: Text(
          'Servicios según tu especialidad',
          style: TextStyle(
            color:      context.colors.textPrimary,
            fontSize:   AppSizes.fontXL,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<ServiceRequestBloc, ServiceRequestState>(
        buildWhen: (previous, current) =>
            current is NearbyRequestsLoading ||
            current is NearbyRequestsSuccess ||
            current is NearbyRequestsError,
        builder: (context, state) {
          if (_publishingLocation) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            );
          }

          if (state is NearbyRequestsLoading) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            );
          }

          if (state is NearbyRequestsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off_outlined,
                      color: context.colors.textSecondary,
                      size:  48,
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                    const SizedBox(height: AppSizes.paddingL),
                    OutlinedButton.icon(
                      onPressed: () => _activateAvailability(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is NearbyRequestsSuccess) {
            if (state.requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      color: context.colors.textSecondary,
                      size:  48,
                    ),
                    const SizedBox(height: AppSizes.paddingM),
                    Text(
                      'No hay solicitudes en tu área',
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              itemCount: state.requests.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSizes.paddingM),
              itemBuilder: (context, index) =>
                  _SpecialtyRequestCard(request: state.requests[index]),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SpecialtyRequestCard extends StatelessWidget {
  final ServiceRequestModel request;

  const _SpecialtyRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final requester = request.requester;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color:      context.colors.textSecondary.withOpacity(0.08),
            blurRadius: 8,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: context.colors.primary.withOpacity(0.1),
                backgroundImage: requester?.imageProfile != null
                    ? NetworkImage(requester!.imageProfile!)
                    : null,
                child: requester?.imageProfile == null
                    ? Icon(
                        Icons.person,
                        color: context.colors.primary,
                        size:  26,
                      )
                    : null,
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requester?.fullName.isNotEmpty == true
                          ? requester!.fullName
                          : 'Solicitante',
                      style: TextStyle(
                        color:      context.colors.textPrimary,
                        fontSize:   AppSizes.fontL,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.occupation.name,
                      style: TextStyle(
                        color:      context.colors.primary,
                        fontSize:   AppSizes.fontM,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _SpecialtyStatusBadge(status: request.status),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.paddingS),
              Column(
                children: [
                  _ActionIcon(
                    icon:     Icons.check,
                    color:    Colors.green,
                    tooltip:  'Aceptar',
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  _ActionIcon(
                    icon:     Icons.close,
                    color:    context.colors.error,
                    tooltip:  'Rechazar',
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),

          Text(
            request.description.isEmpty
                ? 'Sin descripción'
                : request.description,
            style: TextStyle(
              color:    context.colors.textPrimary,
              fontSize: AppSizes.fontM,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.paddingS),

          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: context.colors.textSecondary,
                size:  16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  request.direction,
                  style: TextStyle(
                    color:    context.colors.textSecondary,
                    fontSize: AppSizes.fontM,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingXS),

          Row(
            children: [
              Icon(
                Icons.schedule,
                size:  14,
                color: context.colors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _formatElapsed(request.createdAt),
                  style: TextStyle(
                    color:    context.colors.textSecondary,
                    fontSize: AppSizes.fontS,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatElapsed(String createdAt) {
    try {
      final date = DateTime.parse(
        createdAt.endsWith('Z') ? createdAt : '${createdAt}Z',
      ).toLocal();
      final diff = DateTime.now().difference(date);

      if (diff.inMinutes < 1) return 'Justo ahora';
      if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
      if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return createdAt;
    }
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData  icon;
  final Color     color;
  final String    tooltip;
  final VoidCallback onPressed;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width:  40,
        height: 40,
        decoration: BoxDecoration(
          color:        color.withOpacity(0.1),
          shape:        BoxShape.circle,
        ),
        child: Tooltip(
          message: tooltip,
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }
}

class _SpecialtyStatusBadge extends StatelessWidget {
  final String status;

  const _SpecialtyStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical:   AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color:        _statusColor(context).withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Text(
        _statusLabel(),
        style: TextStyle(
          color:      _statusColor(context),
          fontSize:   AppSizes.fontS,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _statusLabel() {
    switch (status) {
      case 'pending':     return 'Pendiente';
      case 'accepted':    return 'Aceptado';
      case 'in_progress': return 'En progreso';
      case 'completed':   return 'Completado';
      case 'cancelled':   return 'Cancelado';
      case 'disputed':    return 'En disputa';
      default:            return status;
    }
  }

  Color _statusColor(BuildContext context) {
    switch (status) {
      case 'pending':     return Colors.orange;
      case 'accepted':    return context.colors.primary;
      case 'in_progress': return Colors.deepOrange;
      case 'completed':   return Colors.green;
      case 'cancelled':   return context.colors.error;
      case 'disputed':    return Colors.red.shade700;
      default:            return context.colors.textSecondary;
    }
  }
}