import 'package:dio/dio.dart';
import '../config/env.dart';
import '../demo/demo_data.dart';

class ApiClient {
  final Dio _dio = Dio(BaseOptions(baseUrl: Env.apiBase));

  Future<Response<dynamic>> get(String path) async {
    if (Env.demo) {
      switch (path) {
        case '/profile/me':
          return Response(
            requestOptions: RequestOptions(path: path),
            data: DemoData.profile,
            statusCode: 200,
          );
      }
    }
    return _dio.get(path);
  }
  // Add post/put/delete similarly with demo guards if needed
}