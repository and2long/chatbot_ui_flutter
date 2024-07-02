import 'package:hive/hive.dart';

import 'chat_message.dart';

part 'conversation.g.dart';

@HiveType(typeId: 1)
class Conversation extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<ChatMessage> messages;

  Conversation({required this.name, required this.messages});
}
