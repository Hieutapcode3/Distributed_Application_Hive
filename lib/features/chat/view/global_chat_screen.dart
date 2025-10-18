import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:distributed_application_hive/features/chat/data/message_model.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:distributed_application_hive/app/web_socket.dart';

// 🔹 Provider cho WebSocketService
final webSocketProvider = Provider<WebSocketService>(
  (ref) => WebSocketService(),
);

class GlobalChatScreen extends ConsumerStatefulWidget {
  final UserModel currentUser;

  const GlobalChatScreen({super.key, required this.currentUser});

  @override
  ConsumerState<GlobalChatScreen> createState() => _GlobalChatScreenState();
}

class _GlobalChatScreenState extends ConsumerState<GlobalChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Auto-scroll xuống dưới cùng khi màn hình được mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final wsService = ref.read(webSocketProvider);

    final message = MessageModel(
      id: uuid.v4(),
      senderId: widget.currentUser.uid,
      senderName: widget.currentUser.name,
      timestamp: DateTime.now(),
      roomId: "global",
      content: text,
    );

    wsService.sendMessage(message);
    _controller.clear();

    // Cuộn xuống tin nhắn mới
    Future.delayed(const Duration(milliseconds: 150), () {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageBox = Hive.box<MessageModel>('messageBox');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '🌍 Global Chat',
          style: TextStyle(color: Colors.black, fontFamily: 'Caros'),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔹 Danh sách tin nhắn
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: messageBox.listenable(),
              builder: (context, Box<MessageModel> box, _) {
                final messages =
                    box.values.where((m) => m.roomId == "global").toList()
                      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
                print("Total messages in global chat: ${messages.length}");

                // Auto-scroll khi có tin nhắn mới
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      '💬 Chưa có tin nhắn nào',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.currentUser.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(
                                  'assets/image/mtp.jpg',
                                ),
                              ),
                            ),

                          Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    msg.senderName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? const Color.fromRGBO(32, 160, 144, 1)
                                      : const Color.fromRGBO(242, 247, 251, 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  msg.content,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
