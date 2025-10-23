import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:distributed_application_hive/features/chat/data/message_model.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:distributed_application_hive/app/web_socket.dart';

final webSocketProvider = Provider<WebSocketService>((ref) => WebSocketService());

class PrivateChatScreen extends ConsumerStatefulWidget {
  final UserModel currentUser;
  final UserModel receiver; // người nhận

  const PrivateChatScreen({super.key, required this.currentUser, required this.receiver});

  @override
  ConsumerState<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends ConsumerState<PrivateChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final uuid = const Uuid();

  late String roomId;

  @override
  void initState() {
    super.initState();

    final ids = [widget.currentUser.uid, widget.receiver.uid]..sort();
    roomId = ids.join('_');

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
      timestamp: DateTime.now().toUtc(),
      roomId: roomId,
      receiverId: widget.receiver.uid,
      isGroup: false,
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
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  (widget.receiver.profilePictureUrl != null && widget.receiver.profilePictureUrl!.isNotEmpty)
                  ? NetworkImage(widget.receiver.profilePictureUrl!)
                  : const AssetImage('assets/image/mtp.jpg') as ImageProvider,
            ),
            const SizedBox(width: 8),
            Text(widget.receiver.name, style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 🔹 Danh sách tin nhắn
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: messageBox.listenable(),
              builder: (context, Box<MessageModel> box, _) {
                final messages = box.values.where((m) => m.roomId == roomId).map((m) {
                  final ts = m.timestamp.isUtc ? m.timestamp : m.timestamp.toUtc();
                  return m.copyWith(timestamp: ts);
                }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));

                // Auto-scroll khi có tin nhắn mới
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('💬 Chưa có tin nhắn nào', style: TextStyle(color: Colors.black54)),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.currentUser.uid;

                    final localTime = msg.timestamp.toLocal();

                    bool showDateHeader = false;
                    if (index == 0) {
                      showDateHeader = true;
                    } else {
                      final prevMsg = messages[index - 1];
                      final currentDateUtc = DateUtils.dateOnly(msg.timestamp.toUtc());
                      final prevDateUtc = DateUtils.dateOnly(prevMsg.timestamp.toUtc());
                      if (currentDateUtc.isAfter(prevDateUtc)) {
                        showDateHeader = true;
                      }
                    }

                    final nowUtc = DateTime.now().toUtc();
                    final localDate = msg.timestamp.toLocal();
                    final currentDateUtc = DateUtils.dateOnly(localDate.toUtc());
                    final todayUtc = DateUtils.dateOnly(nowUtc);
                    final yesterdayUtc = DateUtils.dateOnly(nowUtc.subtract(const Duration(days: 1)));

                    String formattedDate;
                    if (currentDateUtc == todayUtc) {
                      formattedDate = "Hôm nay";
                    } else if (currentDateUtc == yesterdayUtc) {
                      formattedDate = "Hôm qua";
                    } else {
                      formattedDate = "${localDate.day}/${localDate.month}/${localDate.year}";
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              ),
                            ),
                          ),
                        Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundImage:
                                        (widget.receiver.profilePictureUrl != null &&
                                            widget.receiver.profilePictureUrl!.isNotEmpty)
                                        ? NetworkImage(widget.receiver.profilePictureUrl!)
                                        : const AssetImage('assets/image/mtp.jpg') as ImageProvider,
                                  ),
                                ),
                              Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                                    child: Text(msg.content, style: const TextStyle(color: Colors.black, fontSize: 15)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      '${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 10, color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // 🔹 Ô nhập tin nhắn
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      hintStyle: const TextStyle(color: Colors.black54),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
