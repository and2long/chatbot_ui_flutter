import 'dart:io';

import 'package:chatbotui/core/network/http.dart';
import 'package:chatbotui/i18n/i18n.dart';
import 'package:chatbotui/pages/home.dart';
import 'package:chatbotui/store.dart';
import 'package:chatbotui/theme.dart';
import 'package:chatbotui/utils/common_util.dart';
import 'package:chatbotui/utils/sp_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SPUtil.init().then((value) {
    XHttp.init();
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
  void initState() {
    super.initState();
    EasyLoading.instance
      ..maskType = EasyLoadingMaskType.black
      ..indicatorSize = 30.0;
  }

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
          // 项目本地化资源代理
          S.delegate,
        ],
        // 支持的语言
        supportedLocales: S.supportedLocales,
        locale: Locale(value.languageCode),
        home: const HomePage(),
        builder: EasyLoading.init(
          builder: (context, child) => GestureDetector(
            onTap: () => CommonUtil.hideKeyboard(context),
            child: child,
          ),
        ),
      );
    });
  }
}
