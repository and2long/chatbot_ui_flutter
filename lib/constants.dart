import 'package:flutter/material.dart';

class ConstantsKeyCache {
  ConstantsKeyCache._();
  static String keyLanguageCode = 'LANGUAGE_CODE';
  static String keyTokenType = "TOKEN_TYPE";
  static String keyAccessToken = "ACCESS_TOKEN";
  static String keyRefreshToken = "REFRESH_TOKEN";
  static String keyFCMToken = "FCM_TOKEN";
  static String keyIsFirst = "IS_FIRST";
  static String keyUser = "USER";
  static String keyOllamaServerBaseUrl = "OLLAMA_SERVER_BASE_URL";
}

class ConstantsHttp {
  ConstantsHttp._();

  static const String baseUrl = '';
}

const appBarHeight = kToolbarHeight;
const tileHeight = 55.0;
const ollamaServerBaseUrl = 'http://localhost:11434/api';

const conversationBox = 'conversations';
