import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 0)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String content;

  @HiveField(1)
  bool isUser; // 是否为用户发送的消息

  ChatMessage({required this.content, required this.isUser});
}
