import 'package:chatbotui/utils/sp_util.dart';
import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:provider/provider.dart';

/// 全局状态管理
class Store {
  Store._internal();

  // 初始化
  static init(Widget child) {
    return MultiProvider(
      providers: [
        // 国际化
        ChangeNotifierProvider.value(
            value: LocaleStore(SPUtil.getLanguageCode())),
        ChangeNotifierProvider.value(value: InfoStore()),
      ],
      child: child,
    );
  }
}

/// 语言
class LocaleStore with ChangeNotifier {
  String _languageCode;

  LocaleStore(this._languageCode);

  String get languageCode => _languageCode;

  void setLanguageCode(String languageCode) {
    _languageCode = languageCode;
    SPUtil.setLanguageCode(languageCode);
    notifyListeners();
  }
}

class InfoStore with ChangeNotifier {
  List<Model> _modles = [];
  String _baseUrl = 'http://localhost:11434/api';

  List<Model> get models => _modles;
  String get baseUrl => _baseUrl;

  void updateModels(List<Model> value) {
    _modles = value;
    notifyListeners();
  }

  void updateBaseUrl(String value) {
    _baseUrl = value;
    notifyListeners();
  }
}
