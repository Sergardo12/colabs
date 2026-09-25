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
import '../../../chat/bloc/chat_bloc.dart';
import '../../../chat/bloc/chat_event.dart';
import '../../../chat/bloc/chat_state.dart';
import '../../../chat/models/conversation_model.dart';
import '../../../../core/routes/app_router.dart';

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
      ).timeout(const Duration(seconds: 15));
    } catch (_) {
      return null;
    }
  }

  Future<void> _activateAvailability() async {
    if (_publishingLocation) return;
    setState(() => _publishingLocation = true);

    try {
      final position = await _getCurrentPosition();
      if (!mounted) return;

      if (position == null) {
        _stopPublishing();
        context
            .read<ServiceRequestBloc>()
            .add(const NearbyRequestsLocationUnavailable());
        return;
      }

      _lastPosition = position;
      await _republishLocation();
    } catch (_) {
      if (!mounted) return;
      _stopPublishing();
      context
          .read<ServiceRequestBloc>()
          .add(const NearbyRequestsLocationUnavailable());
      return;
    }

    if (!mounted) return;
    _stopPublishing();
    context.read<ServiceRequestBloc>().add(const NearbyRequestsLoadRequested());
    // Carga las conversaciones solo si aún no las trajo (MyRequestsPage ya lo
    // hace al montar, evitar duplicar peticiones al arrancar)
    final chatState = context.read<ChatBloc>().state;
    if (chatState is! ConversationsLoaded &&
        chatState is! ConversationsLoading) {
      context.read<ChatBloc>().add(const ConversationsLoadRequested());
    }
    _publishTimer?.cancel();
    _publishTimer = Timer.periodic(_publishInterval, (_) {
      _republishLocation();
    });
  }

  void _stopPublishing() {
    if (mounted) setState(() => _publishingLocation = false);
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
      body: BlocListener<ChatBloc, ChatState>(
        listenWhen: (previous, current) =>
            current is ChatInitial && previous is! ChatInitial,
        listener: (context, state) {
          if (context.mounted) {
            context.read<ChatBloc>().add(const ConversationsLoadRequested());
          }
        },
        child: BlocListener<ServiceRequestBloc, ServiceRequestState>(
          listenWhen: (previous, current) =>
              current is StartWorkSuccess || current is StartWorkError,
          listener: (context, state) {
            if (state is StartWorkSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Trabajo iniciado — servicio en progreso'),
                  ),
                );
            } else if (state is StartWorkError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
            }
          },
          child: BlocBuilder<ServiceRequestBloc, ServiceRequestState>(
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

            return BlocBuilder<ChatBloc, ChatState>(
              builder: (context, chatState) {
                final conversations = chatState is ConversationsLoaded
                    ? chatState.conversations
                    : <ConversationModel>[];

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  itemCount: state.requests.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSizes.paddingM),
                  itemBuilder: (context, index) {
                    final nearbyRequest = state.requests[index];
                    final dialogContext = context;

                    final convList = conversations
                        .where((c) => c.serviceRequestId == nearbyRequest.id)
                        .toList();
                    final conv = convList.isNotEmpty ? convList.first : null;

                    return GestureDetector(
                      onTap: () => showDialog(
                        context: dialogContext,
                        builder: (dialogCtx) => _ServiceRequestDetailDialog(
                          request: nearbyRequest,
                          conversation: conv,
                          onStartWork: () {
                            Navigator.of(dialogCtx).pop();
                            context.read<ServiceRequestBloc>().add(
                              StartWorkRequested(
                                serviceRequestId: nearbyRequest.id,
                              ),
                            );
                          },
                          onAccept: conv != null
                              ? () {
                                  Navigator.of(dialogCtx).pop();
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.chat,
                                    arguments: {
                                      'conversation': conv,
                                      'post': null,
                                    },
                                  );
                                }
                              : () {
                                  Navigator.of(dialogCtx).pop();
                                  _openProposalDialog(
                                      dialogContext, nearbyRequest);
                                },
                        ),
                      ),
                      child: _SpecialtyRequestCard(
                        request:  nearbyRequest,
                        onAccept: conv != null
                            ? () => Navigator.pushNamed(
                                  context,
                                  AppRouter.chat,
                                  arguments: {
                                    'conversation': conv,
                                    'post': null,
                                  },
                                )
                            : () => _openProposalDialog(
                                  dialogContext, nearbyRequest),
                        onChatTap: conv != null
                            ? () => Navigator.pushNamed(
                                  context,
                                  AppRouter.chat,
                                  arguments: {
                                    'conversation': conv,
                                    'post': null,
                                  },
                                )
                            : null,
                      ),
                    );
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
          },
          ),
        ),
      ),
    );
  }
}

class _SpecialtyRequestCard extends StatelessWidget {
  final ServiceRequestModel request;
  final VoidCallback        onAccept;
  final VoidCallback?       onChatTap;

  const _SpecialtyRequestCard({
    required this.request,
    required this.onAccept,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    final requester = request.requester;
    final isAcceptedLike =
        request.status == 'accepted' || request.status == 'in_progress';
    final agreedPrice = request.acceptedProposal?.amount;

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
                backgroundImage: requester?.imageProfile?.isNotEmpty == true
                    ? NetworkImage(requester!.imageProfile!)
                    : null,
                child: requester?.imageProfile?.isNotEmpty != true
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
              if (isAcceptedLike)
                Column(
                  children: [
                    if (agreedPrice != null) ...[
                      _QuotePriceBadge(amount: agreedPrice),
                      const SizedBox(height: AppSizes.paddingXS),
                    ],
                    if (onChatTap != null)
                      _ActionIcon(
                        icon:      Icons.chat_bubble_outline,
                        color:     context.colors.primary,
                        tooltip:   'Abrir chat',
                        onPressed: onChatTap!,
                      ),
                  ],
                )
              else
                Column(
                  children: [
                    if (onChatTap != null) ...[
                      _ActionIcon(
                        icon:      Icons.chat_bubble_outline,
                        color:     context.colors.primary,
                        tooltip:   'Negociar en el chat',
                        onPressed: onChatTap!,
                      ),
                      const SizedBox(height: AppSizes.paddingXS),
                    ],
                    _ActionIcon(
                      icon:     Icons.check,
                      color:    Colors.green,
                      tooltip:  'Cotizar',
                      onPressed: onAccept,
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

String _formatDateTime(String createdAt) {
  try {
    final date = DateTime.parse(
      createdAt.endsWith('Z') ? createdAt : '${createdAt}Z',
    ).toLocal();
    return DateFormat('dd/MM/yyyy hh:mm a').format(date);
  } catch (_) {
    return createdAt;
  }
}

void _openProposalDialog(BuildContext context, ServiceRequestModel request) {
  showDialog(
    context: context,
    builder: (_) => _PriceProposalDialog(request: request),
  );
}

class _PriceProposalDialog extends StatefulWidget {
  final ServiceRequestModel request;

  const _PriceProposalDialog({required this.request});

  @override
  State<_PriceProposalDialog> createState() => _PriceProposalDialogState();
}

class _PriceProposalDialogState extends State<_PriceProposalDialog> {
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.trim());
    context.read<ServiceRequestBloc>().add(
          ProposalSendRequested(
            serviceRequestId: widget.request.id,
            amount:           amount,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiceRequestBloc, ServiceRequestState>(
      listenWhen: (prev, curr) =>
          curr is ProposalSent || curr is ProposalSendError,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state is ProposalSent) {
          Navigator.of(context).pop();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Propuesta enviada por S/. ${_amountController.text.trim()}'),
            ),
          );
          context.read<ServiceRequestBloc>().add(const NearbyRequestsLoadRequested());
        } else if (state is ProposalSendError) {
          messenger.showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Dialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical:   AppSizes.paddingXL,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: context.colors.textSecondary,
                      size:  24,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  'Ingresa el precio de tu servicio',
                  style: TextStyle(
                    color:      context.colors.textPrimary,
                    fontSize:   AppSizes.fontL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autofocus: true,
                  decoration: InputDecoration(
                    prefixText: 'S/. ',
                    hintText:   '0.00',
                    filled:     true,
                    fillColor:  context.colors.primary.withOpacity(0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide:   BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    if (amount == null || amount <= 0) {
                      return 'Ingresa un monto mayor a 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.paddingL),
                BlocBuilder<ServiceRequestBloc, ServiceRequestState>(
                  buildWhen: (prev, curr) => curr is ProposalSending,
                  builder: (context, state) {
                    final sending = state is ProposalSending;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: sending ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: Colors.white,
                          minimumSize:
                              const Size.fromHeight(AppSizes.buttonHeight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          ),
                        ),
                        child: sending
                            ? const SizedBox(
                                width:  20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:       Colors.white,
                                ),
                              )
                            : const Text(
                                'Enviar',
                                style: TextStyle(
                                  fontSize:   AppSizes.fontL,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceRequestDetailDialog extends StatelessWidget {
  final ServiceRequestModel request;
  final ConversationModel?  conversation;
  final VoidCallback        onAccept;
  final VoidCallback        onStartWork;

  const _ServiceRequestDetailDialog({
    required this.request,
    required this.onAccept,
    required this.onStartWork,
    this.conversation,
  });

  @override
  Widget build(BuildContext context) {
    final requester = request.requester;

    return Dialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical:   AppSizes.paddingXL,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cierre del modal
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close,
                  color: context.colors.textSecondary,
                  size:  24,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),

            // Encabezado: foto y nombre en vertical, centrado
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: context.colors.primary.withOpacity(0.1),
                    backgroundImage: requester?.imageProfile?.isNotEmpty == true
                        ? NetworkImage(requester!.imageProfile!)
                        : null,
                    child: requester?.imageProfile?.isNotEmpty != true
                        ? Icon(
                            Icons.person,
                            color: context.colors.primary,
                            size: 40,
                          )
                        : null,
                  ),
                  const SizedBox(height: AppSizes.paddingS),
                  Text(
                    requester?.fullName.isNotEmpty == true
                        ? requester!.fullName
                        : 'Solicitante',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:      context.colors.textPrimary,
                      fontSize:   AppSizes.fontL,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Descripción completa del servicio
            Text(
              'Solicita:',
              style: TextStyle(
                color:      context.colors.textSecondary,
                fontSize:   AppSizes.fontS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXS),
            Text(
              request.description.isEmpty
                  ? 'Sin descripción'
                  : request.description,
              style: TextStyle(
                color:    context.colors.textPrimary,
                fontSize: AppSizes.fontM,
                height:   1.4,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Ubicación y distancia
            Text(
              'Ubicación:',
              style: TextStyle(
                color:      context.colors.textSecondary,
                fontSize:   AppSizes.fontS,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXS),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: context.colors.primary,
                  size:  20,
                ),
                const SizedBox(width: AppSizes.paddingS),
                Expanded(
                  child: Text(
                    request.direction,
                    style: TextStyle(
                      color:    context.colors.textPrimary,
                      fontSize: AppSizes.fontM,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingS),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Ver ubicación'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.primary,
                    side:             BorderSide(color: context.colors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingS,
                      vertical:   AppSizes.paddingXS,
                    ),
                    textStyle: TextStyle(
                      fontSize:   AppSizes.fontS,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Distancia y fecha
            Row(
              children: [
                Expanded(
                  child: _InfoBox(
                    label: 'Distancia',
                    value: request.distanceKm != null
                        ? 'a ${request.distanceKm!.toStringAsFixed(1)} km'
                        : 'Cerca de ti',
                    icon: Icons.near_me_outlined,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingS),
                Expanded(
                  child: _InfoBox(
                    label: 'Fecha',
                    value: _formatDateTime(request.createdAt),
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Acción principal — cotizar (pending) o iniciar trabajo (accepted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: request.status == 'accepted'
                ? onStartWork
                : onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                ),
                child: Text(
                  request.status == 'accepted'
                      ? 'COMENZAR TRABAJO'
                      : 'ACEPTAR',
                  style: const TextStyle(
                    fontSize:     AppSizes.fontL,
                    fontWeight:   FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String   label;
  final String   value;
  final IconData icon;

  const _InfoBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingS),
      decoration: BoxDecoration(
        color:        context.colors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: context.colors.primary),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color:    context.colors.textSecondary,
                  fontSize: AppSizes.fontS,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingXS),
          Text(
            value,
            style: TextStyle(
              color:      context.colors.textPrimary,
              fontSize:   AppSizes.fontM,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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

class _QuotePriceBadge extends StatelessWidget {
  final String amount;

  const _QuotePriceBadge({required this.amount});

  @override
  Widget build(BuildContext context) {
    final value = double.tryParse(amount);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS,
        vertical:   AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color:        context.colors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.payments_outlined,
            size:  14,
            color: context.colors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            'S/ ${value?.toStringAsFixed(2) ?? amount}',
            style: TextStyle(
              color:      context.colors.primary,
              fontSize:   AppSizes.fontS,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}