import 'package:chatbotui/constants.dart';
import 'package:chatbotui/models/conversation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatHistory extends StatefulWidget {
  const ChatHistory({super.key});

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Conversation>>(
      valueListenable: Hive.box<Conversation>(conversationBox).listenable(),
      builder: (BuildContext context, Box<Conversation> box, Widget? child) {
        List<Conversation> items = box.values.toList().reversed.toList();
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 0),
          itemBuilder: (c, i) => ListTile(
            title: Text(
              items[i].name,
              style: const TextStyle(overflow: TextOverflow.ellipsis),
            ),
          ),
          separatorBuilder: (c, i) => const Divider(),
          itemCount: items.length,
        );
      },
    );
  }
}
