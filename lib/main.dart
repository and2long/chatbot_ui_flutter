import 'dart:io';

import 'package:chatbotui/constants.dart';
import 'package:chatbotui/i18n/i18n.dart';
import 'package:chatbotui/models/chat_message.dart';
import 'package:chatbotui/models/conversation.dart';
import 'package:chatbotui/pages/home.dart';
import 'package:chatbotui/store.dart';
import 'package:chatbotui/theme.dart';
import 'package:chatbotui/utils/common_util.dart';
import 'package:chatbotui/utils/sp_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ConversationAdapter());
  Hive.registerAdapter(ChatMessageAdapter());
  await Hive.openBox<Conversation>(conversationBox);

  SPUtil.init().then((value) {
    runApp(Store.init(const MyApp()));
  });
  // 安卓透明状态栏
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
  }
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleStore>(
        builder: (BuildContext context, LocaleStore value, Widget? child) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: MyApp.navigatorKey,
        onGenerateTitle: (context) => S.appName,
        theme: AppTheme.lightTheme(context),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          S.delegate,
        ],
        supportedLocales: S.supportedLocales,
        locale: Locale(value.languageCode),
        home: const HomePage(),
        builder: (context, child) => GestureDetector(
          onTap: () => CommonUtil.hideKeyboard(context),
          child: child,
        ),
      );
    });
  }
}
