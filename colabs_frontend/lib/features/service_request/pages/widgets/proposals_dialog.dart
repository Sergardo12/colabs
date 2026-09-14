import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/app_router.dart';
import '../../../chat/bloc/chat_bloc.dart';
import '../../../chat/bloc/chat_event.dart';
import '../../bloc/service_request_bloc.dart';
import '../../bloc/service_request_event.dart';
import '../../bloc/service_request_state.dart';
import '../../models/proposal_model.dart';
import '../../models/service_request_model.dart';

Future<void> showProposalsDialog(
  BuildContext context,
  ServiceRequestModel request,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => ProposalsDialog(request: request),
  );
}

class ProposalsDialog extends StatefulWidget {
  final ServiceRequestModel request;

  const ProposalsDialog({super.key, required this.request});

  @override
  State<ProposalsDialog> createState() => _ProposalsDialogState();
}

class _ProposalsDialogState extends State<ProposalsDialog> {
  @override
  void initState() {
    super.initState();
    context
        .read<ServiceRequestBloc>()
        .add(ProposalsLoadRequested(requestId: widget.request.id));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 460,
          maxHeight: MediaQuery.of(context).size.height * 0.72,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: AppSizes.paddingL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context),
              const SizedBox(height: AppSizes.paddingM),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.paddingM),
              Expanded(
                child: BlocConsumer<ServiceRequestBloc, ServiceRequestState>(
                  listenWhen: (previous, current) =>
                      current is ProposalActionError ||
                      current is ProposalAccepted,
                  listener: (context, state) {
                    if (state is ProposalActionError) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: context.colors.error,
                          ),
                        );
                    }
                    if (state is ProposalAccepted) {
                      context.read<ChatBloc>().add(
                        const ConversationsLoadRequested(),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  buildWhen: (previous, current) =>
                      current is ProposalsLoading ||
                      current is ProposalsLoaded ||
                      current is ProposalsError,
                  builder: (context, state) {
                    if (state is ProposalsLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: context.colors.primary,
                        ),
                      );
                    }
                    if (state is ProposalsError) {
                      return _ErrorState(
                        message: state.message,
                        onRetry: () =>
                            context.read<ServiceRequestBloc>().add(
                                  ProposalsLoadRequested(
                                    requestId: widget.request.id,
                                  ),
                                ),
                      );
                    }
                    if (state is ProposalsLoaded) {
                      if (state.proposals.isEmpty) {
                        return Center(
                          child: Text(
                            'No hay cotizaciones',
                            style:
                                TextStyle(color: context.colors.textSecondary),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: state.proposals.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSizes.paddingS),
                        itemBuilder: (context, index) {
                          final proposal = state.proposals[index];
                          final isPending = state.requestStatus == 'pending';
                          return _ProposalCard(
                            proposal: proposal,
                            enabled: isPending,
                            onProfileTap: () => _openColabProfile(
                              context,
                              proposal.colab.userId,
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Servicio:',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: AppSizes.fontM,
                ),
              ),
              const SizedBox(height: AppSizes.paddingXS),
              Text(
                widget.request.description,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: AppSizes.fontL,
                  //fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, color: context.colors.textSecondary),
        ),
      ],
    );
  }

  void _openColabProfile(BuildContext context, String? userId) {
    if (userId == null || userId.isEmpty) return;
    Navigator.pushNamed(
      context,
      AppRouter.publicProfile,
      arguments: userId,
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final ProposalModel proposal;
  final bool          enabled;
  final VoidCallback  onProfileTap;

  const _ProposalCard({
    required this.proposal,
    required this.enabled,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final colab = proposal.colab;
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingS),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: context.colors.textSecondary.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: context.colors.primary.withOpacity(0.1),
              backgroundImage:
                  colab.imageProfile != null && colab.imageProfile!.isNotEmpty
                      ? NetworkImage(colab.imageProfile!)
                      : null,
              child: colab.imageProfile == null || colab.imageProfile!.isEmpty
                  ? Icon(
                      Icons.person,
                      color: context.colors.primary,
                      size: 24,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: Text(
                    colab.fullName,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: AppSizes.fontM,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      colab.averageRating > 0
                          ? colab.averageRating.toStringAsFixed(1)
                          : 'Sin calificaciones',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: AppSizes.fontS,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingXS),
                Text(
                  'Monto aprox: S/${proposal.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: context.colors.primary,
                    fontSize: AppSizes.fontM,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Evaluar precio con el colaborador(a)',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: AppSizes.fontS,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.paddingS),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                label: 'Aceptar',
                filled: true,
                enabled: enabled,
                onPressed: enabled
                    ? () => context.read<ServiceRequestBloc>().add(
                          ProposalAcceptRequested(
                            proposalId: proposal.id,
                            requestId: proposal.serviceRequestId,
                          ),
                        )
                    : null,
              ),
              const SizedBox(height: AppSizes.paddingS),
              _ActionButton(
                label: 'Rechazar',
                filled: false,
                enabled: enabled,
                onPressed: enabled
                    ? () => context.read<ServiceRequestBloc>().add(
                          ProposalRejectRequested(
                            proposalId: proposal.id,
                            requestId: proposal.serviceRequestId,
                          ),
                        )
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String        label;
  final bool          filled;
  final bool          enabled;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.filled,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = enabled && onPressed != null;
    final bgColor =
        filled ? context.colors.primary : const Color(0xFF2F3437);
    final fgColor = filled ? context.colors.white : Colors.white;

    return SizedBox(
      width: 84,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          onTap: effectiveEnabled ? () => onPressed?.call() : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingS,
              vertical: AppSizes.paddingS,
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: fgColor,
                    fontSize: AppSizes.fontS,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String       message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: context.colors.error, size: 40),
          const SizedBox(height: AppSizes.paddingM),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.white,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
