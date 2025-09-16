import 'package:dio/dio.dart';
final dio = Dio(BaseOptions(baseUrl: 'https://api.YOUR_DOMAIN'));


void configure() {
dio.interceptors.add(InterceptorsWrapper(onRequest:(options, handler){
// attach access token from secure storage
return handler.next(options);
}));
}