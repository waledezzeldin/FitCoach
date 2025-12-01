import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../navigation/app_navigator.dart';

class ApiService {
  ApiService._() : dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
    responseType: ResponseType.json,
    headers: {'Accept': 'application/json'},
  )) {
    _installInterceptors();
  }

  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;

  final Dio dio;
  final _secure = const FlutterSecureStorage();
  String? _preferredLocale;
  bool _demoMode = false;

  static const String _baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
  static const String _kAccess = 'access_token';
  static const String _kRefresh = 'refresh_token';

  Completer<void>? _refreshing;

  Future<String?> getAccessToken() => _secure.read(key: _kAccess);
  Future<String?> getRefreshToken() => _secure.read(key: _kRefresh);

  Future<void> saveTokens({required String access, String? refresh}) async {
    await _secure.write(key: _kAccess, value: access);
    if (refresh != null) {
      await _secure.write(key: _kRefresh, value: refresh);
    }
  }

  Future<void> clearTokens() async {
    await _secure.delete(key: _kAccess);
    await _secure.delete(key: _kRefresh);
  }

  void _installInterceptors() {
    dio.interceptors.clear();

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept-Language'] = _preferredLocale ?? 'en';
        if (_demoMode) {
          options.headers['X-Demo-Mode'] = '1';
        } else {
          options.headers.remove('X-Demo-Mode');
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        final status = err.response?.statusCode;
        final is401 = status == 401;
        final requestOptions = err.requestOptions;

        // Avoid infinite loop
        final retried = requestOptions.extra['retried'] == true;

        if (is401 && !retried) {
          try {
            await _refreshTokenIfNeeded();
            // Retry original with updated token
            final newToken = await getAccessToken();
            if (newToken != null) {
              requestOptions.headers['Authorization'] = 'Bearer $newToken';
            }
            requestOptions.extra['retried'] = true;
            final response = await dio.fetch(requestOptions);
            return handler.resolve(response);
          } catch (_) {
            // Fall through to logout
          }
        }

        // If still unauthorized or refresh failed: logout to /login
        if (is401) {
          await clearTokens();
          final nav = appNavigatorKey.currentState;
          if (nav != null) {
            nav.pushNamedAndRemoveUntil('/login', (_) => false);
          }
        }
        handler.next(err);
      },
    ));

    // Optional logs (enable with --dart-define=HTTP_LOG=true)
    const bool _enableHttpLog = bool.fromEnvironment('HTTP_LOG', defaultValue: true);
    if (_enableHttpLog) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ));
    }
  }

  Future<void> _refreshTokenIfNeeded() async {
    // De-duplicate concurrent refreshes
    if (_refreshing != null) {
      return _refreshing!.future;
    }
    _refreshing = Completer<void>();
    try {
      final refresh = await getRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        throw Exception('No refresh token');
      }
      final tokenDio = Dio(BaseOptions(baseUrl: _baseUrl, headers: {'Accept': 'application/json'}));
      final res = await tokenDio.post('/auth/refresh', data: {'refresh_token': refresh});
      final data = (res.data as Map);
      final newAccess = (data['access_token'] ?? data['accessToken'])?.toString();
      final newRefresh = (data['refresh_token'] ?? data['refreshToken'])?.toString();
      if (newAccess == null || newAccess.isEmpty) throw Exception('Refresh failed');
      await saveTokens(access: newAccess, refresh: newRefresh);
      _refreshing!.complete();
    } catch (e) {
      _refreshing!.completeError(e);
      rethrow;
    } finally {
      _refreshing = null;
    }
  }

  String mapError(Object error, {String fallback = 'Something went wrong'}) {
    if (error is DioException) {
      final msg = error.response?.data is Map
          ? ((error.response?.data['message'])?.toString())
          : null;
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'Network timeout. Try again.';
        case DioExceptionType.badResponse:
          return msg ?? 'Server error (${error.response?.statusCode})';
        case DioExceptionType.connectionError:
          return 'No internet connection.';
        default:
          return msg ?? fallback;
      }
    }
    return fallback;
  }

  void setPreferredLocale(String? localeCode) {
    if (localeCode == null || localeCode.trim().isEmpty) {
      _preferredLocale = null;
      return;
    }
    _preferredLocale = localeCode.trim();
  }

  void setDemoMode(bool value) {
    _demoMode = value;
  }
}
