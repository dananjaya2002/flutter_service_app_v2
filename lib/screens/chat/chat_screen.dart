import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/shop_provider.dart';
import '../../models/shop_model.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markChatAsRead();
  }

  Future<void> _loadMessages() async {
    await Provider.of<ChatProvider>(
      context,
      listen: false,
    ).loadChatMessages(widget.chatId);
  }

  Future<void> _markChatAsRead() async {
    await Provider.of<ChatProvider>(
      context,
      listen: false,
    ).markChatAsRead(widget.chatId);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.uid;

    if (userId != null) {
      try {
        await Provider.of<ChatProvider>(
          context,
          listen: false,
        ).sendMessage(widget.chatId, userId, _messageController.text.trim());
        _messageController.clear();
        _scrollToBottom();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);
    final userId = userProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<ShopModel?>(
          future: shopProvider.getShopById(widget.chatId),
          builder: (context, snapshot) {
            return Text(snapshot.data?.name ?? 'Chat');
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chatProvider.getMessagesForChat(widget.chatId).length,
              itemBuilder: (context, index) {
                final message =
                    chatProvider.getMessagesForChat(widget.chatId)[index];
                final isMe = message.senderId == userId;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isMe
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
