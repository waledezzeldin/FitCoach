import 'dart:io';
import 'package:dio/dio.dart';
import 'api_service.dart';

class ProfileService {
  final _api = ApiService();

  Future<Map<String, dynamic>> me() async {
    final res = await _api.dio.get('/profile/me');
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<String> uploadAvatar(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
    });
    final res = await _api.dio.post('/profile/avatar', data: form);
    // Expect { url: 'https://...' }
    final data = (res.data as Map).cast<String, dynamic>();
    return (data['url'] ?? data['avatarUrl'] ?? '').toString();
  }
}