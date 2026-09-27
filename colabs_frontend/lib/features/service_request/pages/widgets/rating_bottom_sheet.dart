import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../bloc/service_request_bloc.dart';
import '../../bloc/service_request_event.dart';
import '../../bloc/service_request_state.dart';
import '../../models/service_request_model.dart';

/// Abre el BottomSheet de calificación para un servicio completado.
/// Solo debe invocarse desde la card del demandante (HEAD 3).
Future<void> showRatingBottomSheet(
  BuildContext context,
  ServiceRequestModel request,
) {
  return showModalBottomSheet(
    context:              context,
    isScrollControlled:   true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _RatingBottomSheet(request: request),
  );
}

class _RatingBottomSheet extends StatefulWidget {
  final ServiceRequestModel request;

  const _RatingBottomSheet({required this.request});

  @override
  State<_RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<_RatingBottomSheet> {
  int _selectedStars = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedStars < 1) return;
    context.read<ServiceRequestBloc>().add(
      SubmitReviewRequested(
        serviceRequestId: widget.request.id,
        rating:           _selectedStars,
        comment:          _commentController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colab = widget.request.acceptedProposal?.colab;
    final colabName =
        (colab?.fullName.isNotEmpty ?? false) ? colab!.fullName : 'Colaborador';

    return BlocConsumer<ServiceRequestBloc, ServiceRequestState>(
      listenWhen: (previous, current) =>
          current is ReviewSubmitted || current is ReviewSubmitError,
      listener: (context, state) {
        if (state is ReviewSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Calificación enviada!'),
              backgroundColor: context.colors.primary,
            ),
          );
          Navigator.pop(context);
        } else if (state is ReviewSubmitError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is ReviewSubmitting;

        return Padding(
          padding: EdgeInsets.only(
            left:    AppSizes.paddingL,
            right:   AppSizes.paddingL,
            top:     AppSizes.paddingL,
            bottom:  MediaQuery.of(context).viewInsets.bottom +
                AppSizes.paddingL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width:  40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),

              // Encabezado: foto + nombre del colaborador
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: context.colors.background,
                    backgroundImage: colab?.imageProfile != null
                        ? NetworkImage(colab!.imageProfile!)
                        : null,
                    child: colab?.imageProfile == null
                        ? Icon(
                            Icons.person,
                            color: context.colors.textSecondary,
                            size:  28,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Text(
                      colabName,
                      style: TextStyle(
                        color:      context.colors.textPrimary,
                        fontSize:   AppSizes.fontL,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingL),

              // Estrellas interactivas + guía numérica 1..5
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  final isSelected = starValue <= _selectedStars;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedStars = starValue),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingXS,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: isSelected
                                ? Colors.amber
                                : context.colors.textSecondary,
                            size:  40,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$starValue',
                            style: TextStyle(
                              color:    context.colors.textSecondary,
                              fontSize: AppSizes.fontS,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSizes.paddingL),

              // Comentario opcional
              TextField(
                controller:   _commentController,
                maxLines:     4,
                minLines:     3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText:       'Cuéntanos sobre tu experiencia (opcional)',
                  hintStyle: TextStyle(
                    color:    context.colors.textSecondary,
                    fontSize: AppSizes.fontM,
                  ),
                  filled:        true,
                  fillColor:     context.colors.background,
                  contentPadding: const EdgeInsets.all(AppSizes.paddingM),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusM),
                    borderSide:   BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingL),

              // Botón de envío
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:       context.colors.primary,
                    foregroundColor:       Colors.white,
                    disabledBackgroundColor:
                        context.colors.textSecondary.withValues(alpha: 0.3),
                    minimumSize:
                        const Size.fromHeight(AppSizes.buttonHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width:  22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Calificar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
