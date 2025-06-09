import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService;

  UserService() : _apiService = ApiService(baseUrl: ApiConstants.baseUrl);

  Future<Response> getUsers() async {
    return await _apiService.get(ApiConstants.users);
  }

  Future<Response> getUserById(int id) async {
    return await _apiService.get('${ApiConstants.users}/$id');
  }

  Future<Response> createUser(Map<String, dynamic> userData) async {
    return await _apiService.post(ApiConstants.users, data: userData);
  }

  Future<Response> updateUser(int id, Map<String, dynamic> userData) async {
    return await _apiService.put('${ApiConstants.users}/$id', data: userData);
  }

  Future<Response> deleteUser(int id) async {
    return await _apiService.delete('${ApiConstants.users}/$id');
  }
} 