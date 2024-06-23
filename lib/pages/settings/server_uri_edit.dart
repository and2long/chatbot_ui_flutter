import 'package:chatbotui/components/primary_button.dart';
import 'package:chatbotui/components/yt_text_field.dart';
import 'package:chatbotui/store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServerURIEditPage extends StatefulWidget {
  const ServerURIEditPage({super.key});

  @override
  State<ServerURIEditPage> createState() => _ServerURIEditPageState();
}

class _ServerURIEditPageState extends State<ServerURIEditPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _init() {
    _controller.text = context.read<InfoStore>().baseUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ollama Server URI'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                YTTextField(controller: _controller),
              ],
            ),
          ),
          PrimaryButton(
            text: 'Save',
            margin: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: MediaQuery.of(context).padding.bottom + 16),
            onPressed: () {
              String value = _controller.text.trim();
              if (value.isNotEmpty) {
                context.read<InfoStore>().updateOllamaServerBaseUrl(value);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
