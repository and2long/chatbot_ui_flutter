import 'package:chatbotui/components/yt_text_field.dart';
import 'package:chatbotui/store.dart';
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
  final List<Message> _messages = [];

  final client = OllamaClient();
  Model? _selectedModel;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _inputController.dispose();
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
                          child: Text(
                              'No modles were found on your Local machine!'),
                        )
                      : Container()),
              SafeArea(
                child: YTTextField(
                  margin: const EdgeInsets.all(16),
                  controller: _inputController,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: _onSendBtnPressed, icon: Icon(Icons.send))
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

  void _onSendBtnPressed() {
    String text = _inputController.text.trim();
    if (text.isNotEmpty) {
      _send2LLM(text);
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

  Future<List<Model>?> _listModels() async {
    ModelsResponse res = await client.listModels();
    List<Model>? models = res.models;
    if (models != null && mounted) {
      context.read<InfoStore>().updateModels(models);
    }
    return models;
  }

  void _send2LLM(String q) async {
    Log.i(_tag, '[Me]: $q');
    Log.d(_tag, '--> $q');
    String model = _selectedModel!.model!;
    _messages.add(Message(role: MessageRole.user, content: q));
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
    _messages.add(Message(role: MessageRole.system, content: a));
  }
}
