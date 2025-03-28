import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_model.dart';
import '../chat/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.user?.uid ?? '';
    final isServiceProvider = userProvider.isServiceProvider;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: isServiceProvider ? 'Customer Chats' : 'My Chats',
              icon: const Icon(Icons.chat),
            ),
            if (isServiceProvider)
              const Tab(
                text: 'Service Requests',
                icon: Icon(Icons.call_received),
              )
            else
              const Tab(text: 'Service Requests', icon: Icon(Icons.call_made)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Chat List
          _buildChatList(userId, isServiceProvider),

          // Tab 2: Service Requests
          _buildServiceRequestsList(userId, isServiceProvider),
        ],
      ),
    );
  }

  Widget _buildChatList(String userId, bool isServiceProvider) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return StreamBuilder<List<ChatModel>>(
          stream: chatProvider.getUserChats(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final chats = snapshot.data ?? [];

            if (chats.isEmpty) {
              return const Center(
                child: Text(
                  'No chats yet. Start a conversation from a shop page.',
                ),
              );
            }

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildChatTile(chat, isServiceProvider, userId);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChatTile(ChatModel chat, bool isServiceProvider, String userId) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final otherPartyId = isServiceProvider ? chat.customerId : chat.shopId;

    // TODO: Get other user's name and profile pic from database
    final otherPartyName = isServiceProvider ? 'Customer' : 'Shop';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
        child: const Icon(Icons.person),
      ),
      title: Text(otherPartyName),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            DateFormat.jm().format(chat.lastMessageTime),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          if (!chat.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: () {
        chatProvider.setActiveChat(chat.id);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen(chatId: chat.id)),
        );
      },
    );
  }

  Widget _buildServiceRequestsList(String userId, bool isServiceProvider) {
    return const Center(
      child: Text('Service requests will be displayed here.'),
    );
    // TODO: Implement service requests list
  }
}
