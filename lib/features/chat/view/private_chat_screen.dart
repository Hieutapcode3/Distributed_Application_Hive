import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:distributed_application_hive/features/chat/data/message_model.dart';
import 'package:distributed_application_hive/features/auth/data/user_model.dart';
import 'package:distributed_application_hive/app/web_socket.dart';
import 'package:distributed_application_hive/features/home/utils/chat_helpers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

final webSocketProvider = Provider<WebSocketService>(
  (ref) => WebSocketService(),
);

class PrivateChatScreen extends ConsumerStatefulWidget {
  final UserModel currentUser;
  final UserModel receiver; // 🆕 người nhận

  const PrivateChatScreen({
    super.key,
    required this.currentUser,
    required this.receiver,
  });

  @override
  ConsumerState<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends ConsumerState<PrivateChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final uuid = const Uuid();
  final ImagePicker _imagePicker = ImagePicker();
  late String roomId;

  @override
  void initState() {
    super.initState();
    // 🆕 Tạo roomId cố định cho 2 người (tránh trùng)
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
      timestamp: DateTime.now(),
      roomId: roomId,
      content: text,
    );

    wsService.sendMessage(message);
    _controller.clear();

    // Cuộn xuống tin nhắn mới
    Future.delayed(const Duration(milliseconds: 150), () {
      _scrollToBottom();
    });
  }

  void _handleAttachment() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final fileName = result.files.single.name;
        final fileSize = result.files.single.size;

        // Gửi thông tin file (trong thực tế sẽ upload file lên server)
        final wsService = ref.read(webSocketProvider);
        final message = MessageModel(
          id: uuid.v4(),
          senderId: widget.currentUser.uid,
          senderName: widget.currentUser.name,
          timestamp: DateTime.now(),
          roomId: roomId,
          content: '📎 $fileName (${_formatFileSize(fileSize)})',
        );

        wsService.sendMessage(message);
        _scrollToBottom();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  void _handleDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final fileName = result.files.single.name;
        final fileSize = result.files.single.size;

        final wsService = ref.read(webSocketProvider);
        final message = MessageModel(
          id: uuid.v4(),
          senderId: widget.currentUser.uid,
          senderName: widget.currentUser.name,
          timestamp: DateTime.now(),
          roomId: roomId,
          content: '📄 $fileName (${_formatFileSize(fileSize)})',
        );

        wsService.sendMessage(message);
        _scrollToBottom();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking document: $e')));
    }
  }

  void _handleCamera() async {
    try {
      // Kiểm tra quyền camera
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final fileName = image.name;
        final fileSize = await file.length();

        final wsService = ref.read(webSocketProvider);
        final message = MessageModel(
          id: uuid.v4(),
          senderId: widget.currentUser.uid,
          senderName: widget.currentUser.name,
          timestamp: DateTime.now(),
          roomId: roomId,
          content: '📷 Photo: $fileName (${_formatFileSize(fileSize)})',
        );

        wsService.sendMessage(message);
        _scrollToBottom();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
                  (widget.receiver.profilePictureUrl != null &&
                      widget.receiver.profilePictureUrl!.isNotEmpty)
                  ? NetworkImage(widget.receiver.profilePictureUrl!)
                  : const AssetImage('assets/image/mtp.jpg') as ImageProvider,
            ),
            const SizedBox(width: 8),
            Text(
              widget.receiver.name,
              style: const TextStyle(color: Colors.black),
            ),
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
                final messages =
                    box.values.where((m) => m.roomId == roomId).toList()
                      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

                // Auto-scroll khi có tin nhắn mới
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      '💬 Chưa có tin nhắn nào',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.currentUser.uid;
                    final previousMessage = index > 0
                        ? messages[index - 1]
                        : null;
                    final shouldShowDate = ChatHelpers.shouldShowDateHeader(
                      msg.timestamp,
                      previousMessage?.timestamp,
                    );

                    return Column(
                      children: [
                        // Hiển thị ngày nếu cần
                        if (shouldShowDate)
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              ChatHelpers.formatDate(msg.timestamp),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        // Tin nhắn
                        Align(
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
                                    radius: 18,
                                    backgroundImage:
                                        (widget.receiver.profilePictureUrl !=
                                                null &&
                                            widget
                                                .receiver
                                                .profilePictureUrl!
                                                .isNotEmpty)
                                        ? NetworkImage(
                                            widget.receiver.profilePictureUrl!,
                                          )
                                        : const AssetImage(
                                                'assets/image/mtp.jpg',
                                              )
                                              as ImageProvider,
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
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? const Color.fromRGBO(
                                              32,
                                              160,
                                              144,
                                              1,
                                            )
                                          : const Color.fromRGBO(
                                              242,
                                              247,
                                              251,
                                              1,
                                            ),
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
                                      ChatHelpers.formatTimeWithAMPM(
                                        msg.timestamp,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black54,
                                      ),
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

          // 🔹 Ô nhập tin nhắn với các tính năng
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Attachment button
                GestureDetector(
                  onTap: _handleAttachment,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset('assets/image/Clip.png'),
                  ),
                ),

                // Text input field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Write your message',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
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

                // Document button
                GestureDetector(
                  onTap: _handleDocument,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/image/files.png',
                      color: Colors.black,
                    ),
                  ),
                ),

                // Camera button
                GestureDetector(
                  onTap: _handleCamera,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset('assets/image/camera 01.png'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
