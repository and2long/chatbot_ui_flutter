import 'package:dio/dio.dart';
import 'package:chatbotui/core/event_bus.dart';
import 'package:chatbotui/enums.dart';
import 'package:chatbotui/utils/sp_util.dart';

class AuthInterceptor extends Interceptor {
  static bool isRefreshing = false;
  static List<Map<String, dynamic>> requestList = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers
        .putIfAbsent("Accept-Language", () => SPUtil.getLanguageCode());
    options.headers.putIfAbsent("Authorization",
        () => '${SPUtil.getTokenType()} ${SPUtil.getAccessToken()}');
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      EventBus().fire(AuthEvent.unauthenticated);
    }
    super.onError(err, handler);
  }
}
