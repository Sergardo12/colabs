import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_router.dart';
import '../../chat/bloc/chat_bloc.dart';
import '../../chat/bloc/chat_event.dart';
import '../../chat/bloc/chat_state.dart';
import '../../chat/models/conversation_model.dart';
import '../bloc/service_request_bloc.dart';
import '../bloc/service_request_event.dart';
import '../bloc/service_request_state.dart';
import '../models/service_request_model.dart';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceRequestBloc>().add(
      const MyRequestsLoadRequested(),
    );
    context.read<ChatBloc>().add(const ConversationsLoadRequested());
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
          'Mis solicitudes',
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
        child: BlocBuilder<ServiceRequestBloc, ServiceRequestState>(
          builder: (context, state) {
          if (state is ServiceRequestLoading) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            );
          }

          if (state is ServiceRequestError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: context.colors.error),
              ),
            );
          }

          if (state is ServiceRequestSuccess) {
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
                      'No tienes solicitudes aún',
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
                    final request = state.requests[index];
                    return _ServiceRequestCard(
                      request:      request,
                      conversation: _findConversation(
                                      conversations, request.id),
                      onChatTap: (conv) => Navigator.pushNamed(
                        context,
                        AppRouter.chat,
                        arguments: {
                          'conversation': conv,
                          'post':         null,
                        },
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
    );
  }

  ConversationModel? _findConversation(
    List<ConversationModel> conversations,
    String serviceRequestId,
  ) {
    try {
      return conversations.firstWhere(
        (c) => c.serviceRequestId == serviceRequestId,
      );
    } catch (_) {
      return null;
    }
  }
}

class _ServiceRequestCard extends StatelessWidget {
  final ServiceRequestModel  request;
  final ConversationModel?   conversation;
  final void Function(ConversationModel) onChatTap;

  const _ServiceRequestCard({
    required this.request,
    required this.conversation,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
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
            children: [
              Icon(
                Icons.build_outlined,
                color: context.colors.primary,
                size:  20,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Expanded(
                child: Text(
                  request.occupation.name,
                  style: TextStyle(
                    color:      context.colors.textPrimary,
                    fontSize:   AppSizes.fontL,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _StatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),

          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: context.colors.textSecondary,
                size:  16,
              ),
              const SizedBox(width: AppSizes.paddingXS),
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

          Text(
            request.description,
            style: TextStyle(
              color:    context.colors.textPrimary,
              fontSize: AppSizes.fontM,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSizes.paddingM),

          Row(
            children: [
              Icon(
                Icons.access_time,
                color: context.colors.textSecondary,
                size:  14,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(request.createdAt),
                style: TextStyle(
                  color:    context.colors.textSecondary,
                  fontSize: AppSizes.fontS,
                ),
              ),
              const Spacer(),

              if (conversation != null)
                GestureDetector(
                  onTap: () => onChatTap(conversation!),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.paddingS),
                    decoration: BoxDecoration(
                      color:        context.colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      color: context.colors.primary,
                      size:  18,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String createdAt) {
    final date = DateTime.parse(
      createdAt.endsWith('Z') ? createdAt : '${createdAt}Z',
    ).toLocal();
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

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
      default:            return context.colors.textSecondary;
    }
  }
}
