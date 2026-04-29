import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final chatService = ChatService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: chatService.getUserChats(auth.currentUser!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No Messages Yet',
              subtitle: 'Connect with sellers to ask questions about products.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chats.length,
            itemBuilder: (context, i) {
              final chat = chats[i];
              // Find other participant
              final otherId = chat.participants.firstWhere((id) => id != auth.currentUser!.id);
              final otherName = chat.participantNames[otherId] ?? 'User';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)],
                ),
                child: ListTile(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.chatDetail,
                    arguments: {
                      'chatId': chat.id,
                      'otherUserName': otherName,
                      'otherUserId': otherId,
                    },
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.azureSurface,
                    child: Text(otherName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(otherName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(
                        DateFormat('HH:mm').format(chat.lastMessageTime),
                        style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
