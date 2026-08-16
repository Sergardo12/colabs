import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_router.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'widgets/conversation_tile.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const ConversationsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation:       0,
        title: Text(
          'Mensajes',
          style: TextStyle(
            color:      context.colors.textPrimary,
            fontSize:   AppSizes.fontXL,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocListener<ChatBloc, ChatState>(
        listenWhen: (previous, current) =>
            previous is! ConversationsLoaded && current is ChatInitial,
        listener: (context, state) {
          if (context.mounted) {
            context.read<ChatBloc>().add(const ConversationsLoadRequested());
          }
        },
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ConversationsLoading) {
              return Center(
                child: CircularProgressIndicator(color: context.colors.primary),
              );
            }

            if (state is ChatError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: context.colors.error),
                ),
              );
            }

            if (state is ConversationsLoaded) {
              if (state.conversations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: context.colors.textSecondary,
                        size:  48,
                      ),
                      const SizedBox(height: AppSizes.paddingM),
                      Text(
                        'No tienes conversaciones aún',
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount:    state.conversations.length,
                separatorBuilder: (_, __) => const SizedBox.shrink(),
                itemBuilder: (context, index) {
                  final conversation = state.conversations[index];
                  final profileState  = context.read<ProfileBloc>().state;
                  final currentUserId = profileState is ProfileSuccess
                      ? profileState.user.id
                      : '';
                  return ConversationTile(
                    conversation:  conversation,
                    currentUserId: currentUserId,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.chat,
                      arguments: {
                        'conversation': conversation,
                        'post':         null,
                      },
                    ),
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
}
