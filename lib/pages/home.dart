import 'package:chatbotui/components/yt_text_field.dart';
import 'package:chatbotui/components/yt_tile.dart';
import 'package:chatbotui/i18n/i18n.dart';
import 'package:chatbotui/pages/settings.dart';
import 'package:chatbotui/store.dart';
import 'package:chatbotui/theme.dart';
import 'package:chatbotui/utils/log_util.dart';
import 'package:chatbotui/utils/navigator_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
  late OllamaClient _ollamaClient;
  Model? _selectedModel;
  bool _showClearBtn = false;
  bool _sendBtnEnable = false;

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
            title: Text(S.appName),
            centerTitle: false,
            actions: _buildAppBarActions(store.models),
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
              _buildInputPanel(),
            ],
          ),
          drawer: _buildDrawer(),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: themeColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.appName,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'This is a Chatbot UI for Ollama.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white),
                )
              ],
            ),
          ),
          const Expanded(
            // TODO 2024-06-23 chat history
            child: Text('TODO: Chat History'),
          ),
          const Divider(),
          Container(
            margin:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: YTTile(
              leading: const Icon(Icons.settings),
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                NavigatorUtil.push(context, const SettingsPage());
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions(List models) {
    return [
      PopupMenuButton<Model>(
        itemBuilder: (context) {
          return List.generate(models.length, (index) {
            Model model = models[index];
            return PopupMenuItem<Model>(
              value: model,
              child: Text(model.model ?? ''),
            );
          });
        },
        onSelected: (value) {
          setState(() {
            _selectedModel = value;
          });
        },
        initialValue: _selectedModel,
        child: Row(
          children: [
            Text(_selectedModel?.model ?? ''),
            const Icon(Icons.arrow_drop_down)
          ],
        ),
      ),
      IconButton(
        onPressed: () {
          setState(() {
            _messages.clear();
          });
        },
        icon: const Icon(CupertinoIcons.create),
      ),
      const SizedBox(width: 8),
    ];
  }

  Widget _buildInputPanel() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: Divider.createBorderSide(context)),
      ),
      padding: EdgeInsets.only(
        top: 8,
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: YTTextField(
              controller: _inputController,
              hintText: 'Prompt',
              onChanged: (value) {
                setState(() {
                  _sendBtnEnable = value.isNotEmpty;
                  _showClearBtn = value.isNotEmpty;
                });
              },
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _showClearBtn
                      ? IconButton(
                          onPressed: _clearInput,
                          icon: const Icon(CupertinoIcons.clear_circled),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: _onSendBtnPressed,
            child: Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                  color: _sendBtnEnable ? themeColor : Colors.grey.shade400,
                  borderRadius: const BorderRadius.all(Radius.circular(48))),
              child: Icon(
                CupertinoIcons.up_arrow,
                color: _sendBtnEnable ? Colors.white : Colors.grey.shade300,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _clearInput() {
    _inputController.clear();
    setState(() {
      _showClearBtn = false;
      _sendBtnEnable = false;
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
    _ollamaClient = OllamaClient(baseUrl: context.read<InfoStore>().baseUrl);
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 16, top: 16),
              child: Row(children: [
                msg.role == MessageRole.user
                    ? const Icon(CupertinoIcons.profile_circled)
                    : const Icon(CupertinoIcons.rocket),
                const SizedBox(width: 8),
                Text(msg.role == MessageRole.user ? 'Me' : 'Chatbot')
              ]),
            ),
            Container(
              margin: const EdgeInsets.only(
                  top: 8, left: 50, right: 16, bottom: 16),
              child: MarkdownBody(
                styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
                selectable: true,
                data: msg.content,
              ),
            ),
          ],
        );
      },
      itemCount: _messages.length,
    );
  }

  Future<List<Model>?> _listModels() async {
    ModelsResponse res = await _ollamaClient.listModels();
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
    final stream = _ollamaClient.generateChatCompletionStream(
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
