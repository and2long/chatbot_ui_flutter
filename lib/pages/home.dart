import 'package:chatbotui/components/yt_text_field.dart';
import 'package:chatbotui/store.dart';
import 'package:chatbotui/theme.dart';
import 'package:chatbotui/utils/log_util.dart';
import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final String _tag = 'Home';
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _chatListController = ScrollController();
  final List<Message> _messages = [];
  final client = OllamaClient();
  Model? _selectedModel;
  bool _showSendBtn = false;
  bool _showClearBtn = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _chatListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InfoStore>(
      builder: (BuildContext context, InfoStore store, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chatbot UI'),
            actions: [
              TextButton(
                  onPressed: () {
                    // TODO 2024-06-22 switch model
                  },
                  child: Text(_selectedModel?.model ?? ''))
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: _selectedModel == null
                    ? const Center(
                        child:
                            Text('No modles were found on your Local machine!'),
                      )
                    : _buildChatList(),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(top: Divider.createBorderSide(context)),
                ),
                padding: EdgeInsets.only(
                  top: 8,
                  left: 16,
                  right: 16,
                  bottom: 16 + MediaQuery.of(context).padding.bottom,
                ),
                child: YTTextField(
                  controller: _inputController,
                  hintText: 'Enter your question',
                  onChanged: (value) {
                    setState(() {
                      _showSendBtn = value.isNotEmpty;
                      _showClearBtn = value.isNotEmpty;
                    });
                  },
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _showClearBtn
                          ? IconButton(
                              onPressed: _clearInput,
                              icon: const Icon(Icons.clear),
                            )
                          : Container(),
                      _showSendBtn
                          ? IconButton(
                              onPressed: _onSendBtnPressed,
                              icon: const Icon(
                                Icons.send,
                                color: themeColor,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _clearInput() {
    _inputController.clear();
    setState(() {
      _showClearBtn = false;
      _showSendBtn = false;
    });
  }

  void _onSendBtnPressed() {
    String text = _inputController.text.trim();
    if (text.isNotEmpty) {
      _send2LLM(text);
      _clearInput();
    }
  }

  void _init() async {
    List<Model>? models = await _listModels();
    if (models != null && models.isNotEmpty) {
      setState(() {
        _selectedModel = models.first;
      });
    }
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _chatListController,
      itemBuilder: (context, index) {
        Message msg = _messages[index];
        return Container(
          margin: const EdgeInsets.all(16),
          child: Text(
            '${msg.role == MessageRole.user ? '' : 'GPT:\n'}${msg.content}',
            textAlign:
                msg.role == MessageRole.user ? TextAlign.right : TextAlign.left,
          ),
        );
      },
      itemCount: _messages.length,
    );
  }

  Future<List<Model>?> _listModels() async {
    ModelsResponse res = await client.listModels();
    List<Model>? models = res.models;
    if (models != null && mounted) {
      context.read<InfoStore>().updateModels(models);
    }
    return models;
  }

  void _addMessageToChatList(Message msg) {
    setState(() {
      _messages.add(msg);
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _chatListController.jumpTo(
        _chatListController.position.maxScrollExtent,
      );
    });
  }

  void _send2LLM(String q) async {
    Log.i(_tag, '[Me]: $q');
    Log.d(_tag, '--> $q');
    String model = _selectedModel!.model!;
    _addMessageToChatList(Message(role: MessageRole.user, content: q));
    final stream = client.generateChatCompletionStream(
      request: GenerateChatCompletionRequest(
        model: model,
        messages: _messages,
        keepAlive: 1,
      ),
    );
    String a = '';
    await for (final res in stream) {
      String value = (res.message?.content ?? '');
      Log.d(_tag, '<-- $value');
      a += value;
    }
    Log.i(_tag, '[$model]: $a');
    _addMessageToChatList(Message(role: MessageRole.system, content: a));
  }
}
