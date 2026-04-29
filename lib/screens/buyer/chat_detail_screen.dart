import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../services/cloudinary_service.dart';
import '../../widgets/loading_widget.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String otherUserId;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.otherUserId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageCtrl = TextEditingController();
  final ChatService _chatService = ChatService();
  final ImagePicker _picker = ImagePicker();
  bool _isSharing = false;

  void _sendMessage() {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    _chatService.sendMessage(widget.chatId, auth.currentUser!.id, text);
    _messageCtrl.clear();
  }

  Future<void> _sendImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Take Photo'), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Choose from Gallery'), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
      if (image != null) {
        setState(() => _isSharing = true);
        try {
          final url = await CloudinaryService().uploadImage(File(image.path));
          final auth = context.read<AuthProvider>();
          await _chatService.sendMessage(widget.chatId, auth.currentUser!.id, '', type: MessageType.image, imageUrl: url);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        } finally {
          setState(() => _isSharing = false);
        }
      }
    }
  }

  Future<void> _sendLocation() async {
    setState(() => _isSharing = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        final auth = context.read<AuthProvider>();
        await _chatService.sendMessage(
          widget.chatId, 
          auth.currentUser!.id, 
          '📍 Shared Location', 
          type: MessageType.location, 
          latitude: position.latitude, 
          longitude: position.longitude
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    } finally {
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.azureSurface,
              child: Text(widget.otherUserName[0].toUpperCase(), style: const TextStyle(fontSize: 14, color: AppColors.primary)),
            ),
            const SizedBox(width: 10),
            Text(widget.otherUserName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }

                final messages = snapshot.data ?? [];

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId == auth.currentUser!.id;
                    return _ChatBubble(message: msg, isMe: isMe);
                  },
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_a_photo_outlined, color: AppColors.textSecondary, size: 22),
              onPressed: _isSharing ? null : _sendImage,
            ),
            IconButton(
              icon: const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 22),
              onPressed: _isSharing ? null : _sendLocation,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: _messageCtrl,
                enabled: !_isSharing,
                decoration: InputDecoration(
                  hintText: _isSharing ? 'Sending...' : 'Type a message...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  fillColor: AppColors.background,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isSharing ? null : _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isSharing ? Colors.grey : AppColors.primary, 
                  shape: BoxShape.circle
                ),
                child: _isSharing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  void _openMap() async {
    if (message.latitude != null && message.longitude != null) {
      final url = 'https://www.google.com/maps/search/?api=1&query=${message.latitude},${message.longitude}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: message.type == MessageType.image ? const EdgeInsets.all(4) : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.azureSurface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.type == MessageType.image && message.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  message.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                ),
              )
            else if (message.type == MessageType.location)
              GestureDetector(
                onTap: _openMap,
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Icon(Icons.map_outlined, size: 40)),
                    ),
                    const SizedBox(height: 8),
                    const Text('Tap to view on Google Maps', style: TextStyle(fontSize: 12, decoration: TextDecoration.underline)),
                  ],
                ),
              )
            else
              Text(
                message.text,
                style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 14),
              ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(color: isMe ? Colors.white70 : AppColors.textHint, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
