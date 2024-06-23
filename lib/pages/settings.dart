import 'package:chatbotui/components/yt_tile.dart';
import 'package:chatbotui/store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<InfoStore>(
      builder: (BuildContext context, InfoStore value, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: ListView(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                child: Text(
                  'Ollama',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              YTTile(
                title: 'Server URI',
                subtitle: value.baseUrl,
              ),
              YTTile(
                title: 'Default Model',
                subtitle: value.models.firstOrNull?.model ?? '',
              ),
            ],
          ),
        );
      },
    );
  }
}
